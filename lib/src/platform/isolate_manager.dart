import 'dart:async';
import 'dart:isolate';

import 'package:dartllm/src/core/exceptions/exceptions.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:dartllm/src/utils/platform_utils.dart';

/// Types of requests that can be sent to the bridge isolate.
enum IsolateRequestType {
  /// Load a model from a file path.
  loadModel,

  /// Unload a model and free resources.
  unloadModel,

  /// Generate text from a prompt.
  generate,

  /// Generate text with streaming.
  generateStream,

  /// Generate embeddings.
  embed,

  /// Tokenize text.
  tokenize,

  /// Detokenize tokens.
  detokenize,

  /// Get model information.
  getModelInfo,

  /// Shutdown the isolate.
  shutdown,
}

/// A request sent to the bridge isolate.
class IsolateRequest {
  /// Unique identifier for this request.
  final int requestId;

  /// Type of operation to perform.
  final IsolateRequestType type;

  /// Request payload data.
  final Object? payload;

  /// Creates an isolate request.
  const IsolateRequest({
    required this.requestId,
    required this.type,
    this.payload,
  });
}

/// A response from the bridge isolate.
class IsolateResponse {
  /// ID of the request this response corresponds to.
  final int requestId;

  /// Whether the operation succeeded.
  final bool success;

  /// Response data (on success).
  final Object? data;

  /// Error message (on failure).
  final String? errorMessage;

  /// Error type for reconstructing exceptions.
  final String? errorType;

  /// Creates a successful response.
  const IsolateResponse.success({
    required this.requestId,
    this.data,
  })  : success = true,
        errorMessage = null,
        errorType = null;

  /// Creates a failure response.
  const IsolateResponse.failure({
    required this.requestId,
    required this.errorMessage,
    this.errorType,
  })  : success = false,
        data = null;
}

/// A chunk from a streaming response.
class IsolateStreamChunk {
  /// ID of the request this chunk belongs to.
  final int requestId;

  /// The chunk data, or null for the final chunk.
  final Object? data;

  /// Whether this is the final chunk.
  final bool isLast;

  /// Creates a stream chunk.
  const IsolateStreamChunk({
    required this.requestId,
    required this.data,
    required this.isLast,
  });
}

/// Manages communication between the main isolate and the bridge isolate.
///
/// The bridge isolate performs all inference operations to keep the
/// main/UI isolate responsive. Communication uses Dart's [SendPort]
/// and [ReceivePort] mechanism.
///
/// Threading model:
/// ```
/// ┌──────────────────┐     ┌──────────────────┐
/// │   Main Isolate   │────▶│  Bridge Isolate  │
/// │   (UI Thread)    │◀────│  (Inference)     │
/// └──────────────────┘     └──────────────────┘
///         │                        │
///         │   SendPort/           │   PlatformBinding
///         │   ReceivePort         │   operations
/// ```
///
/// Usage:
/// ```dart
/// final manager = IsolateManager();
/// await manager.start();
///
/// final result = await manager.sendRequest(
///   IsolateRequest(
///     requestId: 1,
///     type: IsolateRequestType.loadModel,
///     payload: loadModelRequest,
///   ),
/// );
///
/// await manager.shutdown();
/// ```
class IsolateManager {
  static const String _loggerName = 'dartllm.platform.isolate';

  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// The bridge isolate instance.
  Isolate? _isolate;

  /// Port for sending requests to the bridge isolate.
  SendPort? _sendPort;

  /// Port for receiving responses from the bridge isolate.
  ReceivePort? _receivePort;

  /// Whether the manager is running.
  bool _isRunning = false;

  /// Whether shutdown has been requested.
  bool _isShuttingDown = false;

  /// Counter for generating unique request IDs.
  int _nextRequestId = 1;

  /// Pending request completers indexed by request ID.
  final Map<int, Completer<IsolateResponse>> _pendingRequests = {};

  /// Stream controllers for streaming requests.
  final Map<int, StreamController<IsolateStreamChunk>> _streamControllers = {};

  /// Creates a new isolate manager.
  IsolateManager();

  /// Whether the bridge isolate is running.
  bool get isRunning => _isRunning;

  /// Starts the bridge isolate.
  ///
  /// This must be called before sending any requests.
  Future<void> start() async {
    if (_isRunning) {
      return;
    }

    if (!PlatformUtils.supportsMultiThreading) {
      _logger.warning('Platform does not support multi-threading');
      throw UnsupportedPlatformException(PlatformUtils.platformName);
    }

    _logger.info('Starting bridge isolate');

    _receivePort = ReceivePort();

    // Wait for the SendPort from the child isolate
    final sendPortCompleter = Completer<SendPort>();

    _receivePort!.listen((message) {
      if (message is SendPort && !sendPortCompleter.isCompleted) {
        sendPortCompleter.complete(message);
      } else {
        _handleMessage(message);
      }
    });

    _isolate = await Isolate.spawn(
      _bridgeIsolateEntryPoint,
      _receivePort!.sendPort,
    );

    _sendPort = await sendPortCompleter.future;
    _isRunning = true;

    _logger.info('Bridge isolate started');
  }

  /// Handles messages received from the bridge isolate.
  void _handleMessage(dynamic message) {
    if (message is IsolateResponse) {
      _handleResponse(message);
    } else if (message is IsolateStreamChunk) {
      _handleStreamChunk(message);
    } else {
      _logger.warning('Received unknown message type: ${message.runtimeType}');
    }
  }

  /// Handles a response message.
  void _handleResponse(IsolateResponse response) {
    final completer = _pendingRequests.remove(response.requestId);
    if (completer == null) {
      _logger.warning('Received response for unknown request: ${response.requestId}');
      return;
    }

    completer.complete(response);
  }

  /// Handles a stream chunk message.
  void _handleStreamChunk(IsolateStreamChunk chunk) {
    final controller = _streamControllers[chunk.requestId];
    if (controller == null) {
      _logger.warning('Received chunk for unknown stream: ${chunk.requestId}');
      return;
    }

    controller.add(chunk);

    if (chunk.isLast) {
      controller.close();
      _streamControllers.remove(chunk.requestId);
    }
  }

  /// Sends a request to the bridge isolate and waits for a response.
  ///
  /// Throws if the isolate is not running or the request fails.
  Future<IsolateResponse> sendRequest(IsolateRequest request) async {
    _checkRunning();

    final completer = Completer<IsolateResponse>();
    _pendingRequests[request.requestId] = completer;

    _sendPort!.send(request);

    final response = await completer.future;

    if (!response.success) {
      throw _reconstructException(response);
    }

    return response;
  }

  /// Sends a streaming request to the bridge isolate.
  ///
  /// Returns a stream that yields chunks as they are produced.
  Stream<IsolateStreamChunk> sendStreamingRequest(IsolateRequest request) {
    _checkRunning();

    final controller = StreamController<IsolateStreamChunk>();
    _streamControllers[request.requestId] = controller;

    _sendPort!.send(request);

    return controller.stream;
  }

  /// Generates a unique request ID.
  int generateRequestId() => _nextRequestId++;

  /// Checks that the isolate is running.
  void _checkRunning() {
    if (!_isRunning) {
      throw StateError('IsolateManager is not running. Call start() first.');
    }
    if (_isShuttingDown) {
      throw StateError('IsolateManager is shutting down.');
    }
  }

  /// Reconstructs an exception from a failure response.
  Exception _reconstructException(IsolateResponse response) {
    final message = response.errorMessage ?? 'Unknown error';
    final type = response.errorType;

    return switch (type) {
      'ModelNotFoundException' => ModelNotFoundException(message),
      'InvalidModelException' => InvalidModelException('', details: message),
      'InsufficientMemoryException' => InsufficientMemoryException(),
      'GenerationException' => GenerationException(message),
      'TokenizationException' => TokenizationException(message),
      'LLMPlatformException' => LLMPlatformException(message),
      _ => DartLLMException(message),
    };
  }

  /// Shuts down the bridge isolate.
  ///
  /// Waits for pending requests to complete before terminating.
  Future<void> shutdown() async {
    if (!_isRunning || _isShuttingDown) {
      return;
    }

    _isShuttingDown = true;
    _logger.info('Shutting down bridge isolate');

    // Send shutdown request directly (bypass _checkRunning since we're shutting down)
    if (_sendPort != null) {
      final shutdownRequest = IsolateRequest(
        requestId: generateRequestId(),
        type: IsolateRequestType.shutdown,
      );

      final completer = Completer<IsolateResponse>();
      _pendingRequests[shutdownRequest.requestId] = completer;

      _sendPort!.send(shutdownRequest);

      try {
        await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _logger.warning('Shutdown timed out, forcing termination');
            return const IsolateResponse.success(requestId: 0);
          },
        );
      } on Exception catch (error) {
        _logger.error('Error during shutdown', error);
      }
    }

    // Complete pending requests with errors
    for (final entry in _pendingRequests.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(
          StateError('IsolateManager was shut down'),
        );
      }
    }
    _pendingRequests.clear();

    // Close stream controllers
    for (final controller in _streamControllers.values) {
      await controller.close();
    }
    _streamControllers.clear();

    // Kill isolate and close ports
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;

    _isRunning = false;
    _isShuttingDown = false;

    _logger.info('Bridge isolate shut down');
  }
}

/// Entry point for the bridge isolate.
///
/// This function runs in the bridge isolate and handles incoming
/// requests from the main isolate.
Future<void> _bridgeIsolateEntryPoint(SendPort mainSendPort) async {
  final logger = DartLLMLogger('dartllm.platform.bridge');
  logger.info('Bridge isolate starting');

  // Create receive port for incoming requests
  final receivePort = ReceivePort();

  // Send our send port back to the main isolate
  mainSendPort.send(receivePort.sendPort);

  // Process incoming requests
  await for (final message in receivePort) {
    if (message is IsolateRequest) {
      await _handleRequest(message, mainSendPort, logger);

      if (message.type == IsolateRequestType.shutdown) {
        logger.info('Bridge isolate received shutdown request');
        break;
      }
    }
  }

  receivePort.close();
  logger.info('Bridge isolate terminated');
}

/// Handles a request in the bridge isolate.
Future<void> _handleRequest(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Processing request ${request.requestId}: ${request.type}');

  try {
    switch (request.type) {
      case IsolateRequestType.loadModel:
        await _handleLoadModel(request, sendPort, logger);

      case IsolateRequestType.unloadModel:
        await _handleUnloadModel(request, sendPort, logger);

      case IsolateRequestType.generate:
        await _handleGenerate(request, sendPort, logger);

      case IsolateRequestType.generateStream:
        await _handleGenerateStream(request, sendPort, logger);

      case IsolateRequestType.embed:
        await _handleEmbed(request, sendPort, logger);

      case IsolateRequestType.tokenize:
        await _handleTokenize(request, sendPort, logger);

      case IsolateRequestType.detokenize:
        await _handleDetokenize(request, sendPort, logger);

      case IsolateRequestType.getModelInfo:
        await _handleGetModelInfo(request, sendPort, logger);

      case IsolateRequestType.shutdown:
        sendPort.send(IsolateResponse.success(requestId: request.requestId));
    }
  } on DartLLMException catch (error) {
    sendPort.send(IsolateResponse.failure(
      requestId: request.requestId,
      errorMessage: error.message,
      errorType: error.runtimeType.toString(),
    ));
  } on Exception catch (error) {
    sendPort.send(IsolateResponse.failure(
      requestId: request.requestId,
      errorMessage: error.toString(),
    ));
  }
}

// Request handlers - these will be implemented when integrating with the binding
Future<void> _handleLoadModel(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  // Integration point: call binding.loadModel(request.payload)
  logger.debug('Load model request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}

Future<void> _handleUnloadModel(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Unload model request received');
  sendPort.send(IsolateResponse.success(requestId: request.requestId));
}

Future<void> _handleGenerate(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Generate request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}

Future<void> _handleGenerateStream(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Generate stream request received');
  sendPort.send(IsolateStreamChunk(
    requestId: request.requestId,
    data: null,
    isLast: true,
  ));
}

Future<void> _handleEmbed(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Embed request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}

Future<void> _handleTokenize(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Tokenize request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}

Future<void> _handleDetokenize(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Detokenize request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}

Future<void> _handleGetModelInfo(
  IsolateRequest request,
  SendPort sendPort,
  DartLLMLogger logger,
) async {
  logger.debug('Get model info request received');
  sendPort.send(IsolateResponse.failure(
    requestId: request.requestId,
    errorMessage: 'Native library not available',
    errorType: 'LLMPlatformException',
  ));
}
