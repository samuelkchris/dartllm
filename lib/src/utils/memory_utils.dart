/// Memory calculation and formatting utilities.
///
/// Provides helpers for:
/// - Estimating model memory requirements
/// - Formatting byte sizes for display
/// - Memory unit conversions
abstract final class MemoryUtils {
  /// Bytes per kilobyte (1024).
  static const int bytesPerKB = 1024;

  /// Bytes per megabyte (1024^2).
  static const int bytesPerMB = 1024 * 1024;

  /// Bytes per gigabyte (1024^3).
  static const int bytesPerGB = 1024 * 1024 * 1024;

  /// Formats a byte count as a human-readable string.
  ///
  /// Automatically selects the appropriate unit (B, KB, MB, GB, TB).
  ///
  /// ```dart
  /// MemoryUtils.formatBytes(1536); // "1.5 KB"
  /// MemoryUtils.formatBytes(4200000000); // "3.9 GB"
  /// ```
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes < 0) {
      throw ArgumentError.value(bytes, 'bytes', 'Must be non-negative');
    }

    if (bytes < bytesPerKB) {
      return '$bytes B';
    } else if (bytes < bytesPerMB) {
      final kb = bytes / bytesPerKB;
      return '${kb.toStringAsFixed(decimals)} KB';
    } else if (bytes < bytesPerGB) {
      final mb = bytes / bytesPerMB;
      return '${mb.toStringAsFixed(decimals)} MB';
    } else {
      final gb = bytes / bytesPerGB;
      return '${gb.toStringAsFixed(decimals)} GB';
    }
  }

  /// Converts megabytes to bytes.
  static int mbToBytes(int megabytes) => megabytes * bytesPerMB;

  /// Converts gigabytes to bytes.
  static int gbToBytes(int gigabytes) => gigabytes * bytesPerGB;

  /// Converts bytes to megabytes (truncated).
  static int bytesToMB(int bytes) => bytes ~/ bytesPerMB;

  /// Converts bytes to gigabytes (truncated).
  static int bytesToGB(int bytes) => bytes ~/ bytesPerGB;

  /// Estimates model weight memory usage.
  ///
  /// Calculates approximate memory for model weights based on
  /// parameter count and bits per weight.
  ///
  /// ```dart
  /// // 7B parameters with 4-bit quantization
  /// final bytes = MemoryUtils.estimateModelWeightsBytes(
  ///   parameterCount: 7000000000,
  ///   bitsPerWeight: 4.5,
  /// );
  /// // ~3.9 GB
  /// ```
  static int estimateModelWeightsBytes({
    required int parameterCount,
    required double bitsPerWeight,
  }) {
    if (parameterCount < 0) {
      throw ArgumentError.value(
        parameterCount,
        'parameterCount',
        'Must be non-negative',
      );
    }
    if (bitsPerWeight <= 0) {
      throw ArgumentError.value(
        bitsPerWeight,
        'bitsPerWeight',
        'Must be positive',
      );
    }
    return (parameterCount * bitsPerWeight / 8).ceil();
  }

  /// Estimates KV cache memory usage.
  ///
  /// Calculates approximate memory for the key-value cache based on
  /// model dimensions and context size.
  ///
  /// ```dart
  /// // 7B model with 4096 context
  /// final bytes = MemoryUtils.estimateKVCacheBytes(
  ///   contextSize: 4096,
  ///   layerCount: 32,
  ///   headDimension: 128,
  ///   headCount: 32,
  ///   bytesPerElement: 2, // FP16
  /// );
  /// ```
  static int estimateKVCacheBytes({
    required int contextSize,
    required int layerCount,
    required int headDimension,
    required int headCount,
    int bytesPerElement = 2,
  }) {
    if (contextSize <= 0) {
      throw ArgumentError.value(
        contextSize,
        'contextSize',
        'Must be positive',
      );
    }
    // KV cache size = 2 (K + V) * layers * context * heads * head_dim * precision
    return 2 * layerCount * contextSize * headCount * headDimension *
        bytesPerElement;
  }

  /// Estimates total model memory requirements.
  ///
  /// Combines model weights, KV cache, and scratch buffer estimates.
  ///
  /// ```dart
  /// final estimate = MemoryUtils.estimateTotalMemory(
  ///   parameterCount: 7000000000,
  ///   bitsPerWeight: 4.5,
  ///   contextSize: 4096,
  ///   layerCount: 32,
  ///   headDimension: 128,
  ///   headCount: 32,
  /// );
  ///
  /// print('Total: ${MemoryUtils.formatBytes(estimate.total)}');
  /// ```
  static MemoryEstimate estimateTotalMemory({
    required int parameterCount,
    required double bitsPerWeight,
    required int contextSize,
    required int layerCount,
    required int headDimension,
    required int headCount,
    int kvCacheBytesPerElement = 2,
    int scratchBufferBytes = 512 * 1024 * 1024, // 512 MB default
  }) {
    final weights = estimateModelWeightsBytes(
      parameterCount: parameterCount,
      bitsPerWeight: bitsPerWeight,
    );

    final kvCache = estimateKVCacheBytes(
      contextSize: contextSize,
      layerCount: layerCount,
      headDimension: headDimension,
      headCount: headCount,
      bytesPerElement: kvCacheBytesPerElement,
    );

    return MemoryEstimate(
      modelWeights: weights,
      kvCache: kvCache,
      scratchBuffer: scratchBufferBytes,
    );
  }

  /// Bits per weight for common quantization formats.
  static const Map<String, double> quantizationBits = {
    'Q2_K': 2.5,
    'Q3_K_S': 3.0,
    'Q3_K_M': 3.5,
    'Q4_0': 4.0,
    'Q4_K_S': 4.0,
    'Q4_K_M': 4.5,
    'Q5_0': 5.0,
    'Q5_K_S': 5.0,
    'Q5_K_M': 5.5,
    'Q6_K': 6.0,
    'Q8_0': 8.0,
    'F16': 16.0,
    'F32': 32.0,
  };

  /// Returns bits per weight for a quantization format.
  ///
  /// Returns null if the format is unknown.
  static double? getBitsPerWeight(String quantization) {
    final upper = quantization.toUpperCase();
    return quantizationBits[upper];
  }
}

/// Memory usage estimate breakdown.
class MemoryEstimate {
  /// Memory for model weights (read-only, potentially mmap'd).
  final int modelWeights;

  /// Memory for KV cache (scales with context size).
  final int kvCache;

  /// Memory for computation scratch buffers.
  final int scratchBuffer;

  /// Creates a memory estimate.
  const MemoryEstimate({
    required this.modelWeights,
    required this.kvCache,
    required this.scratchBuffer,
  });

  /// Total estimated memory usage.
  int get total => modelWeights + kvCache + scratchBuffer;

  /// Formatted model weights size.
  String get modelWeightsFormatted => MemoryUtils.formatBytes(modelWeights);

  /// Formatted KV cache size.
  String get kvCacheFormatted => MemoryUtils.formatBytes(kvCache);

  /// Formatted scratch buffer size.
  String get scratchBufferFormatted => MemoryUtils.formatBytes(scratchBuffer);

  /// Formatted total size.
  String get totalFormatted => MemoryUtils.formatBytes(total);

  @override
  String toString() {
    return 'MemoryEstimate('
        'weights: $modelWeightsFormatted, '
        'kvCache: $kvCacheFormatted, '
        'scratch: $scratchBufferFormatted, '
        'total: $totalFormatted)';
  }
}
