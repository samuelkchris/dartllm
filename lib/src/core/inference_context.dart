import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/model_info.dart';

/// Represents an active inference session with its own state.
///
/// An inference context maintains the KV cache state, token history,
/// and sampling configuration for a single inference session.
/// Multiple contexts can share the same model weights but have
/// independent state.
///
/// The KV cache stores computed attention key-value pairs, enabling
/// efficient generation of subsequent tokens without recomputing
/// the entire sequence.
class InferenceContext {
  /// Information about the model this context belongs to.
  final ModelInfo modelInfo;

  /// Maximum number of tokens this context can hold.
  final int contextSize;

  /// The type of KV cache quantization being used.
  final KVCacheType kvCacheType;

  /// Tokens currently in the context.
  final List<int> _tokens = [];

  /// Whether this context has been disposed.
  bool _isDisposed = false;

  /// Creates an inference context.
  ///
  /// [modelInfo] describes the model this context belongs to.
  /// [contextSize] is the maximum context window size.
  /// [kvCacheType] specifies the KV cache quantization level.
  InferenceContext({
    required this.modelInfo,
    required this.contextSize,
    this.kvCacheType = KVCacheType.f16,
  });

  /// The current number of tokens in the context.
  int get tokenCount => _tokens.length;

  /// The remaining capacity in tokens.
  int get remainingCapacity => contextSize - tokenCount;

  /// Whether the context is full.
  bool get isFull => tokenCount >= contextSize;

  /// Whether this context has been disposed.
  bool get isDisposed => _isDisposed;

  /// The tokens currently in this context.
  List<int> get tokens => List.unmodifiable(_tokens);

  /// Adds tokens to the context.
  ///
  /// Throws [StateError] if the context has been disposed.
  /// Throws [ArgumentError] if adding the tokens would exceed capacity.
  void addTokens(List<int> newTokens) {
    _checkDisposed();

    if (tokenCount + newTokens.length > contextSize) {
      throw ArgumentError(
        'Cannot add ${newTokens.length} tokens: would exceed context size '
        '($tokenCount + ${newTokens.length} > $contextSize)',
      );
    }

    _tokens.addAll(newTokens);
  }

  /// Clears all tokens from the context.
  ///
  /// This resets the context to its initial state while keeping
  /// the same configuration.
  ///
  /// Throws [StateError] if the context has been disposed.
  void clear() {
    _checkDisposed();
    _tokens.clear();
  }

  /// Truncates the context to keep only the most recent tokens.
  ///
  /// [keepCount] is the number of tokens to retain from the end.
  /// This is useful for sliding window approaches.
  ///
  /// Throws [StateError] if the context has been disposed.
  /// Throws [ArgumentError] if keepCount is negative or exceeds token count.
  void truncate(int keepCount) {
    _checkDisposed();

    if (keepCount < 0) {
      throw ArgumentError('keepCount must be non-negative');
    }

    if (keepCount >= tokenCount) {
      return;
    }

    final removeCount = tokenCount - keepCount;
    _tokens.removeRange(0, removeCount);
  }

  /// Estimates the memory usage of this context in bytes.
  ///
  /// This includes the KV cache memory based on the model dimensions
  /// and current token count.
  int estimateMemoryUsage() {
    final bytesPerElement = switch (kvCacheType) {
      KVCacheType.f16 => 2,
      KVCacheType.q8_0 => 1,
      KVCacheType.q4_0 => 1, // Actually 0.5, but we round up
    };

    // KV cache size: 2 (K+V) × layers × head_dim × sequence_length × bytes
    final kvCacheBytes = 2 *
        modelInfo.layerCount *
        modelInfo.embeddingSize *
        tokenCount *
        bytesPerElement;

    return kvCacheBytes;
  }

  /// Disposes of this context and releases resources.
  ///
  /// After disposing, the context cannot be used.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _tokens.clear();
  }

  /// Checks that the context has not been disposed.
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use disposed InferenceContext');
    }
  }
}
