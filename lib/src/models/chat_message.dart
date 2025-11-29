import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dartllm/src/models/enums.dart';

part 'chat_message.freezed.dart';

/// A message in a conversation with an LLM.
///
/// ChatMessage represents a single turn in a conversation. Each message
/// has a role (system, user, or assistant) and content. User messages
/// may optionally include image data for multimodal models.
///
/// Use the factory constructors to create messages:
/// ```dart
/// final systemMsg = ChatMessage.system('You are a helpful assistant.');
/// final userMsg = ChatMessage.user('Hello!');
/// final assistantMsg = ChatMessage.assistant('Hi there!');
/// ```
///
/// For multimodal models, include images:
/// ```dart
/// final imageMsg = ChatMessage.userWithImage(
///   'What is in this image?',
///   imageBytes,
///   mimeType: 'image/jpeg',
/// );
/// ```
@freezed
sealed class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  /// Creates a system message that establishes the assistant's behavior.
  ///
  /// System messages are processed first and set the context,
  /// personality, and constraints for the assistant. They are
  /// typically not visible to end users.
  ///
  /// [content] describes how the assistant should behave.
  const factory ChatMessage.system(String content) = SystemMessage;

  /// Creates a user message containing text input.
  ///
  /// User messages contain the input that the model should
  /// respond to.
  ///
  /// [content] is the text from the user.
  const factory ChatMessage.user(String content) = UserMessage;

  /// Creates a user message containing both text and an image.
  ///
  /// For multimodal models that support vision capabilities.
  /// The image is provided as raw bytes with its MIME type.
  ///
  /// [content] is the text prompt accompanying the image.
  /// [imageData] is the raw image bytes.
  /// [mimeType] specifies the image format (image/jpeg, image/png, image/webp).
  const factory ChatMessage.userWithImage(
    String content,
    Uint8List imageData, {
    @Default('image/jpeg') String mimeType,
  }) = UserImageMessage;

  /// Creates an assistant message representing model output.
  ///
  /// Assistant messages represent the model's responses. When
  /// included in conversation history, they help maintain
  /// context for multi-turn conversations.
  ///
  /// [content] is the assistant's response text.
  const factory ChatMessage.assistant(String content) = AssistantMessage;

  /// The role of this message in the conversation.
  MessageRole get role => switch (this) {
        SystemMessage() => MessageRole.system,
        UserMessage() => MessageRole.user,
        UserImageMessage() => MessageRole.user,
        AssistantMessage() => MessageRole.assistant,
      };

  /// Whether this message contains an image.
  bool get hasImage => this is UserImageMessage;

  /// The image data if this is a multimodal message, null otherwise.
  Uint8List? get imageData => switch (this) {
        UserImageMessage(:final imageData) => imageData,
        _ => null,
      };

  /// The image MIME type if this is a multimodal message, null otherwise.
  String? get imageMimeType => switch (this) {
        UserImageMessage(:final mimeType) => mimeType,
        _ => null,
      };
}
