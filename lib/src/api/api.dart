/// Public API for DartLLM.
///
/// This library exports the main user-facing classes:
/// - [DartLLM]: Static entry point for model loading and configuration
/// - [LLMModel]: A loaded model ready for inference
///
/// The API layer provides a high-level, user-friendly interface
/// that hides the complexity of the underlying inference engine.
library;

export 'dart_llm.dart';
export 'llm_model.dart';
