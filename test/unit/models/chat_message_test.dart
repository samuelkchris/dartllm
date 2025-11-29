import 'dart:typed_data';

import 'package:dartllm/src/models/chat_message.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:test/test.dart';

void main() {
  group('ChatMessage', () {
    group('system', () {
      test('creates system message with content', () {
        const message = ChatMessage.system('You are a helpful assistant.');

        expect(message.content, equals('You are a helpful assistant.'));
        expect(message.role, equals(MessageRole.system));
        expect(message.hasImage, isFalse);
        expect(message.imageData, isNull);
        expect(message.imageMimeType, isNull);
      });

      test('is instance of SystemMessage', () {
        const message = ChatMessage.system('test');
        expect(message, isA<SystemMessage>());
      });
    });

    group('user', () {
      test('creates user message with content', () {
        const message = ChatMessage.user('Hello!');

        expect(message.content, equals('Hello!'));
        expect(message.role, equals(MessageRole.user));
        expect(message.hasImage, isFalse);
        expect(message.imageData, isNull);
        expect(message.imageMimeType, isNull);
      });

      test('is instance of UserMessage', () {
        const message = ChatMessage.user('test');
        expect(message, isA<UserMessage>());
      });
    });

    group('userWithImage', () {
      test('creates user message with content and image', () {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final message = ChatMessage.userWithImage(
          'What is in this image?',
          imageBytes,
          mimeType: 'image/png',
        );

        expect(message.content, equals('What is in this image?'));
        expect(message.role, equals(MessageRole.user));
        expect(message.hasImage, isTrue);
        expect(message.imageData, equals(imageBytes));
        expect(message.imageMimeType, equals('image/png'));
      });

      test('defaults mimeType to image/jpeg', () {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final message = ChatMessage.userWithImage('test', imageBytes);

        expect(message.imageMimeType, equals('image/jpeg'));
      });

      test('is instance of UserImageMessage', () {
        final message = ChatMessage.userWithImage(
          'test',
          Uint8List.fromList([1, 2, 3]),
        );
        expect(message, isA<UserImageMessage>());
      });
    });

    group('assistant', () {
      test('creates assistant message with content', () {
        const message = ChatMessage.assistant('Hi there!');

        expect(message.content, equals('Hi there!'));
        expect(message.role, equals(MessageRole.assistant));
        expect(message.hasImage, isFalse);
        expect(message.imageData, isNull);
        expect(message.imageMimeType, isNull);
      });

      test('is instance of AssistantMessage', () {
        const message = ChatMessage.assistant('test');
        expect(message, isA<AssistantMessage>());
      });
    });

    group('pattern matching', () {
      test('supports exhaustive switch expression', () {
        const messages = <ChatMessage>[
          ChatMessage.system('system'),
          ChatMessage.user('user'),
          ChatMessage.assistant('assistant'),
        ];

        for (final message in messages) {
          final result = switch (message) {
            SystemMessage(:final content) => 'system: $content',
            UserMessage(:final content) => 'user: $content',
            UserImageMessage(:final content) => 'image: $content',
            AssistantMessage(:final content) => 'assistant: $content',
          };

          expect(result, isNotEmpty);
        }
      });
    });

    group('equality', () {
      test('system messages with same content are equal', () {
        const message1 = ChatMessage.system('test');
        const message2 = ChatMessage.system('test');

        expect(message1, equals(message2));
      });

      test('different message types are not equal', () {
        const system = ChatMessage.system('test');
        const user = ChatMessage.user('test');

        expect(system, isNot(equals(user)));
      });
    });
  });
}
