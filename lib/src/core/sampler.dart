import 'dart:math';

import 'package:dartllm/src/models/generation_config.dart';

/// Token with its probability from the model's output distribution.
class TokenProbability {
  /// The token ID.
  final int token;

  /// The probability (0.0 to 1.0).
  final double probability;

  /// The raw logit value before softmax.
  final double logit;

  /// Creates a token probability entry.
  const TokenProbability({
    required this.token,
    required this.probability,
    required this.logit,
  });

  @override
  String toString() => 'TokenProbability(token: $token, p: $probability)';
}

/// Sampler for selecting tokens from a probability distribution.
///
/// The sampler applies various filtering and transformation strategies
/// to the model's output logits to select the next token. Strategies
/// include temperature scaling, top-k filtering, nucleus sampling,
/// and repetition penalties.
///
/// Sampling is performed in the following order:
/// 1. Apply repetition penalties to logits
/// 2. Apply temperature scaling
/// 3. Convert to probabilities (softmax)
/// 4. Apply top-k filtering
/// 5. Apply nucleus (top-p) filtering
/// 6. Apply min-p filtering
/// 7. Re-normalize and sample
class Sampler {
  final GenerationConfig _config;
  final Random _random;

  /// Recent tokens for repetition penalty calculation.
  final List<int> _recentTokens = [];

  /// Token frequency counts for frequency penalty.
  final Map<int, int> _tokenCounts = {};

  /// Creates a sampler with the given configuration.
  ///
  /// [config] contains the sampling parameters.
  /// [seed] is the random seed for reproducibility. Null for random seed.
  Sampler({
    required GenerationConfig config,
    int? seed,
  })  : _config = config,
        _random = seed != null ? Random(seed) : Random();

  /// Samples a token from the given logits.
  ///
  /// [logits] is a map from token ID to logit value.
  ///
  /// Returns the selected token ID.
  int sample(Map<int, double> logits) {
    if (logits.isEmpty) {
      throw ArgumentError('Cannot sample from empty logits');
    }

    // Step 1: Apply repetition penalties
    var processedLogits = _applyRepetitionPenalties(logits);

    // Step 2: Apply temperature
    processedLogits = _applyTemperature(processedLogits);

    // Step 3: Convert to probabilities
    var probabilities = _softmax(processedLogits);

    // Step 4: Apply top-k filtering
    probabilities = _applyTopK(probabilities);

    // Step 5: Apply nucleus (top-p) filtering
    probabilities = _applyTopP(probabilities);

    // Step 6: Apply min-p filtering
    probabilities = _applyMinP(probabilities);

    // Step 7: Re-normalize and sample
    final normalized = _normalize(probabilities);
    final selectedToken = _sampleFromDistribution(normalized);

    // Update tracking for penalties
    _recordToken(selectedToken);

    return selectedToken;
  }

  /// Records that a token was generated for penalty tracking.
  void _recordToken(int token) {
    _recentTokens.add(token);
    if (_recentTokens.length > _config.repeatLastN) {
      _recentTokens.removeAt(0);
    }

    _tokenCounts[token] = (_tokenCounts[token] ?? 0) + 1;
  }

  /// Applies repetition, frequency, and presence penalties to logits.
  Map<int, double> _applyRepetitionPenalties(Map<int, double> logits) {
    final result = Map<int, double>.from(logits);

    // Repetition penalty: penalize tokens that appear in recent context
    if (_config.repetitionPenalty != 1.0) {
      for (final token in _recentTokens.toSet()) {
        if (result.containsKey(token)) {
          final logit = result[token]!;
          // Apply penalty: divide positive logits, multiply negative
          if (logit > 0) {
            result[token] = logit / _config.repetitionPenalty;
          } else {
            result[token] = logit * _config.repetitionPenalty;
          }
        }
      }
    }

    // Frequency penalty: penalize based on how often token has appeared
    if (_config.frequencyPenalty != 0.0) {
      for (final entry in _tokenCounts.entries) {
        if (result.containsKey(entry.key)) {
          result[entry.key] =
              result[entry.key]! - _config.frequencyPenalty * entry.value;
        }
      }
    }

    // Presence penalty: penalize tokens that have appeared at all
    if (_config.presencePenalty != 0.0) {
      for (final token in _tokenCounts.keys) {
        if (result.containsKey(token)) {
          result[token] = result[token]! - _config.presencePenalty;
        }
      }
    }

    return result;
  }

  /// Applies temperature scaling to logits.
  Map<int, double> _applyTemperature(Map<int, double> logits) {
    if (_config.temperature == 0.0) {
      // Greedy decoding: return only the max logit
      final maxEntry = logits.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      return {maxEntry.key: maxEntry.value};
    }

    if (_config.temperature == 1.0) {
      return logits;
    }

    return logits.map(
      (token, logit) => MapEntry(token, logit / _config.temperature),
    );
  }

  /// Converts logits to probabilities using softmax.
  Map<int, double> _softmax(Map<int, double> logits) {
    if (logits.isEmpty) return {};

    // Find max for numerical stability
    final maxLogit = logits.values.reduce(max);

    // Compute exp(logit - max) for each token
    final expMap = <int, double>{};
    double sumExp = 0.0;

    for (final entry in logits.entries) {
      final expValue = exp(entry.value - maxLogit);
      expMap[entry.key] = expValue;
      sumExp += expValue;
    }

    // Normalize to get probabilities
    if (sumExp == 0.0) sumExp = 1.0;
    return expMap.map((token, expVal) => MapEntry(token, expVal / sumExp));
  }

  /// Applies top-k filtering, keeping only the k most probable tokens.
  Map<int, double> _applyTopK(Map<int, double> probabilities) {
    if (_config.topK <= 0 || _config.topK >= probabilities.length) {
      return probabilities;
    }

    final sorted = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(_config.topK));
  }

  /// Applies nucleus (top-p) sampling, keeping tokens until cumulative
  /// probability exceeds p.
  Map<int, double> _applyTopP(Map<int, double> probabilities) {
    if (_config.topP >= 1.0) {
      return probabilities;
    }

    final sorted = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <int, double>{};
    double cumulative = 0.0;

    for (final entry in sorted) {
      result[entry.key] = entry.value;
      cumulative += entry.value;
      if (cumulative >= _config.topP) {
        break;
      }
    }

    return result;
  }

  /// Applies min-p filtering, removing tokens with probability below
  /// minP * maxProbability.
  Map<int, double> _applyMinP(Map<int, double> probabilities) {
    if (_config.minP <= 0.0 || probabilities.isEmpty) {
      return probabilities;
    }

    final maxProb = probabilities.values.reduce(max);
    final threshold = _config.minP * maxProb;

    final result = <int, double>{};
    for (final entry in probabilities.entries) {
      if (entry.value >= threshold) {
        result[entry.key] = entry.value;
      }
    }

    // Ensure at least one token remains
    if (result.isEmpty) {
      final maxEntry = probabilities.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      return {maxEntry.key: maxEntry.value};
    }

    return result;
  }

  /// Normalizes probabilities to sum to 1.0.
  Map<int, double> _normalize(Map<int, double> probabilities) {
    if (probabilities.isEmpty) return {};

    final sum = probabilities.values.fold(0.0, (a, b) => a + b);
    if (sum == 0.0) return probabilities;

    return probabilities.map((token, prob) => MapEntry(token, prob / sum));
  }

  /// Samples a token from the probability distribution.
  int _sampleFromDistribution(Map<int, double> probabilities) {
    if (probabilities.isEmpty) {
      throw StateError('Cannot sample from empty distribution');
    }

    if (probabilities.length == 1) {
      return probabilities.keys.first;
    }

    final r = _random.nextDouble();
    double cumulative = 0.0;

    for (final entry in probabilities.entries) {
      cumulative += entry.value;
      if (r <= cumulative) {
        return entry.key;
      }
    }

    // Fallback to last token (handles floating point rounding)
    return probabilities.keys.last;
  }

  /// Resets the sampler state.
  ///
  /// Clears recent token history and frequency counts.
  void reset() {
    _recentTokens.clear();
    _tokenCounts.clear();
  }
}
