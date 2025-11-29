import 'package:dartllm/src/platform/isolate_manager.dart';
import 'package:test/test.dart';

void main() {
  group('IsolateRequest', () {
    test('stores request data', () {
      const request = IsolateRequest(
        requestId: 1,
        type: IsolateRequestType.loadModel,
        payload: 'test payload',
      );

      expect(request.requestId, equals(1));
      expect(request.type, equals(IsolateRequestType.loadModel));
      expect(request.payload, equals('test payload'));
    });

    test('payload is optional', () {
      const request = IsolateRequest(
        requestId: 2,
        type: IsolateRequestType.shutdown,
      );

      expect(request.requestId, equals(2));
      expect(request.type, equals(IsolateRequestType.shutdown));
      expect(request.payload, isNull);
    });
  });

  group('IsolateResponse', () {
    test('success response stores data', () {
      const response = IsolateResponse.success(
        requestId: 1,
        data: {'key': 'value'},
      );

      expect(response.requestId, equals(1));
      expect(response.success, isTrue);
      expect(response.data, equals({'key': 'value'}));
      expect(response.errorMessage, isNull);
      expect(response.errorType, isNull);
    });

    test('failure response stores error details', () {
      const response = IsolateResponse.failure(
        requestId: 2,
        errorMessage: 'Something went wrong',
        errorType: 'TestException',
      );

      expect(response.requestId, equals(2));
      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.errorMessage, equals('Something went wrong'));
      expect(response.errorType, equals('TestException'));
    });
  });

  group('IsolateStreamChunk', () {
    test('stores chunk data', () {
      const chunk = IsolateStreamChunk(
        requestId: 1,
        data: 'chunk data',
        isLast: false,
      );

      expect(chunk.requestId, equals(1));
      expect(chunk.data, equals('chunk data'));
      expect(chunk.isLast, isFalse);
    });

    test('marks final chunk', () {
      const chunk = IsolateStreamChunk(
        requestId: 1,
        data: null,
        isLast: true,
      );

      expect(chunk.isLast, isTrue);
    });
  });

  group('IsolateRequestType', () {
    test('contains all expected types', () {
      expect(IsolateRequestType.values, hasLength(9));
      expect(IsolateRequestType.values, contains(IsolateRequestType.loadModel));
      expect(
          IsolateRequestType.values, contains(IsolateRequestType.unloadModel));
      expect(IsolateRequestType.values, contains(IsolateRequestType.generate));
      expect(IsolateRequestType.values,
          contains(IsolateRequestType.generateStream));
      expect(IsolateRequestType.values, contains(IsolateRequestType.embed));
      expect(IsolateRequestType.values, contains(IsolateRequestType.tokenize));
      expect(
          IsolateRequestType.values, contains(IsolateRequestType.detokenize));
      expect(
          IsolateRequestType.values, contains(IsolateRequestType.getModelInfo));
      expect(IsolateRequestType.values, contains(IsolateRequestType.shutdown));
    });
  });

  group('IsolateManager', () {
    late IsolateManager manager;

    setUp(() {
      manager = IsolateManager();
    });

    tearDown(() async {
      if (manager.isRunning) {
        await manager.shutdown();
      }
    });

    test('isRunning is false initially', () {
      expect(manager.isRunning, isFalse);
    });

    test('can start and shutdown', () async {
      await manager.start();
      expect(manager.isRunning, isTrue);

      await manager.shutdown();
      expect(manager.isRunning, isFalse);
    });

    test('multiple starts are idempotent', () async {
      await manager.start();
      await manager.start();
      expect(manager.isRunning, isTrue);

      await manager.shutdown();
    });

    test('multiple shutdowns are idempotent', () async {
      await manager.start();
      await manager.shutdown();
      await manager.shutdown();
      expect(manager.isRunning, isFalse);
    });

    test('generateRequestId returns unique IDs', () {
      final id1 = manager.generateRequestId();
      final id2 = manager.generateRequestId();
      final id3 = manager.generateRequestId();

      expect(id1, isNot(equals(id2)));
      expect(id2, isNot(equals(id3)));
      expect(id1, isNot(equals(id3)));
    });

    test('sendRequest throws when not running', () async {
      const request = IsolateRequest(
        requestId: 1,
        type: IsolateRequestType.shutdown,
      );

      expect(
        () => manager.sendRequest(request),
        throwsA(isA<StateError>()),
      );
    });

    test('sendStreamingRequest throws when not running', () {
      const request = IsolateRequest(
        requestId: 1,
        type: IsolateRequestType.generateStream,
      );

      expect(
        () => manager.sendStreamingRequest(request),
        throwsA(isA<StateError>()),
      );
    });

    test('can send shutdown request', () async {
      await manager.start();

      final request = IsolateRequest(
        requestId: manager.generateRequestId(),
        type: IsolateRequestType.shutdown,
      );

      // This should complete without error
      final response = await manager.sendRequest(request);
      expect(response.success, isTrue);
    });
  });
}
