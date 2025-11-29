import 'dart:async';

import 'package:dartllm/src/platform/platform_binding.dart';

/// Abstract interface for text tokenization.
///
/// A tokenizer converts text to token IDs (encoding) and token IDs
/// back to text (decoding). Each model has its own vocabulary and
/// tokenization rules.
///
/// The tokenizer is obtained from the model and uses the native
/// tokenization implementation for accuracy.
abstract interface class Tokenizer {
  /// Converts text to a list of token IDs.
  ///
  /// [text] is the input string to tokenize.
  /// [addSpecialTokens] controls whether BOS/EOS tokens are added.
  ///
  /// Returns the list of token IDs representing the text.
  Future<List<int>> encode(String text, {bool addSpecialTokens = true});

  /// Converts token IDs back to text.
  ///
  /// [tokens] is the list of token IDs to decode.
  ///
  /// Returns the decoded text string.
  Future<String> decode(List<int> tokens);

  /// Counts the number of tokens in the given text.
  ///
  /// This is equivalent to `encode(text).length` but may be
  /// more efficient in some implementations.
  Future<int> countTokens(String text);

  /// The vocabulary size of this tokenizer.
  int get vocabularySize;

  /// The BOS (Beginning of Sequence) token ID, if any.
  int? get bosToken;

  /// The EOS (End of Sequence) token ID, if any.
  int? get eosToken;
}

/// Tokenizer implementation that uses the platform binding.
///
/// This tokenizer delegates all operations to the native tokenizer
/// through the platform binding interface.
class PlatformTokenizer implements Tokenizer {
  final PlatformBinding _binding;
  final ModelHandle _handle;

  @override
  final int vocabularySize;

  @override
  final int? bosToken;

  @override
  final int? eosToken;

  /// Creates a platform tokenizer.
  ///
  /// [binding] is the platform binding to use.
  /// [handle] is the handle to the loaded model.
  /// [vocabularySize] is the size of the model's vocabulary.
  /// [bosToken] is the BOS token ID, if any.
  /// [eosToken] is the EOS token ID, if any.
  PlatformTokenizer({
    required PlatformBinding binding,
    required ModelHandle handle,
    required this.vocabularySize,
    this.bosToken,
    this.eosToken,
  })  : _binding = binding,
        _handle = handle;

  @override
  Future<List<int>> encode(String text, {bool addSpecialTokens = true}) async {
    final request = TokenizeRequest(
      modelHandle: _handle,
      text: text,
      addSpecialTokens: addSpecialTokens,
    );
    return _binding.tokenize(request);
  }

  @override
  Future<String> decode(List<int> tokens) async {
    final request = DetokenizeRequest(
      modelHandle: _handle,
      tokens: tokens,
    );
    return _binding.detokenize(request);
  }

  @override
  Future<int> countTokens(String text) async {
    final tokens = await encode(text, addSpecialTokens: false);
    return tokens.length;
  }
}
