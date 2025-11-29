import 'package:dartllm/src/core/chat_template.dart';
import 'package:dartllm/src/models/chat_message.dart';
import 'package:test/test.dart';

void main() {
  final testMessages = [
    const ChatMessage.system('You are a helpful assistant.'),
    const ChatMessage.user('Hello!'),
    const ChatMessage.assistant('Hi there! How can I help you?'),
    const ChatMessage.user('What is 2+2?'),
  ];

  group('ChatMLTemplate', () {
    late ChatMLTemplate template;

    setUp(() {
      template = ChatMLTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('ChatML'));
    });

    test('has correct stop sequences', () {
      expect(template.stopSequences, contains('<|im_end|>'));
      expect(template.stopSequences, contains('<|im_start|>'));
    });

    test('formats system message', () {
      final messages = [const ChatMessage.system('Be helpful.')];
      final prompt = template.apply(messages);

      expect(prompt, contains('<|im_start|>system'));
      expect(prompt, contains('Be helpful.'));
      expect(prompt, contains('<|im_end|>'));
    });

    test('formats user message', () {
      final messages = [const ChatMessage.user('Hello!')];
      final prompt = template.apply(messages);

      expect(prompt, contains('<|im_start|>user'));
      expect(prompt, contains('Hello!'));
      expect(prompt, contains('<|im_end|>'));
    });

    test('formats assistant message', () {
      final messages = [const ChatMessage.assistant('Hi there!')];
      final prompt = template.apply(messages);

      expect(prompt, contains('<|im_start|>assistant'));
      expect(prompt, contains('Hi there!'));
      expect(prompt, contains('<|im_end|>'));
    });

    test('adds generation prompt when requested', () {
      final prompt = template.apply(testMessages, addGenerationPrompt: true);
      expect(prompt, endsWith('<|im_start|>assistant\n'));
    });

    test('omits generation prompt when not requested', () {
      final prompt = template.apply(testMessages, addGenerationPrompt: false);
      expect(prompt, isNot(endsWith('<|im_start|>assistant\n')));
    });

    test('formats full conversation', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<|im_start|>system'));
      expect(prompt, contains('You are a helpful assistant.'));
      expect(prompt, contains('<|im_start|>user'));
      expect(prompt, contains('Hello!'));
      expect(prompt, contains('<|im_start|>assistant'));
      expect(prompt, contains('Hi there!'));
      expect(prompt, contains('What is 2+2?'));
    });

    test('extractResponse removes stop sequences', () {
      final response = template.extractResponse('The answer is 4<|im_end|>');
      expect(response, equals('The answer is 4'));
    });

    test('extractResponse trims whitespace', () {
      final response = template.extractResponse('  Hello  ');
      expect(response, equals('Hello'));
    });
  });

  group('Llama2ChatTemplate', () {
    late Llama2ChatTemplate template;

    setUp(() {
      template = Llama2ChatTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('Llama2Chat'));
    });

    test('has correct stop sequences', () {
      expect(template.stopSequences, contains('</s>'));
      expect(template.stopSequences, contains('[INST]'));
    });

    test('wraps system message in <<SYS>> tags', () {
      final messages = [
        const ChatMessage.system('Be helpful.'),
        const ChatMessage.user('Hi'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('<<SYS>>'));
      expect(prompt, contains('Be helpful.'));
      expect(prompt, contains('<</SYS>>'));
    });

    test('formats user message with [INST] tags', () {
      final messages = [const ChatMessage.user('Hello!')];
      final prompt = template.apply(messages);

      expect(prompt, contains('[INST]'));
      expect(prompt, contains('Hello!'));
      expect(prompt, contains('[/INST]'));
    });

    test('formats assistant message without [INST] tags', () {
      final messages = [
        const ChatMessage.user('Hi'),
        const ChatMessage.assistant('Hello!'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('Hello!'));
      expect(prompt, contains('</s>'));
    });
  });

  group('Llama3InstructTemplate', () {
    late Llama3InstructTemplate template;

    setUp(() {
      template = Llama3InstructTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('Llama3Instruct'));
    });

    test('has correct stop sequences', () {
      expect(template.stopSequences, contains('<|eot_id|>'));
      expect(template.stopSequences, contains('<|end_of_text|>'));
    });

    test('starts with begin_of_text token', () {
      final prompt = template.apply(testMessages);
      expect(prompt, startsWith('<|begin_of_text|>'));
    });

    test('uses header tokens', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<|start_header_id|>system<|end_header_id|>'));
      expect(prompt, contains('<|start_header_id|>user<|end_header_id|>'));
      expect(prompt, contains('<|start_header_id|>assistant<|end_header_id|>'));
    });

    test('uses eot_id for message endings', () {
      final prompt = template.apply(testMessages);
      expect(prompt, contains('<|eot_id|>'));
    });
  });

  group('MistralInstructTemplate', () {
    late MistralInstructTemplate template;

    setUp(() {
      template = MistralInstructTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('MistralInstruct'));
    });

    test('starts with <s> token', () {
      final messages = [const ChatMessage.user('Hi')];
      final prompt = template.apply(messages);
      expect(prompt, startsWith('<s>'));
    });

    test('formats user message with [INST] tags', () {
      final messages = [const ChatMessage.user('Hello!')];
      final prompt = template.apply(messages);

      expect(prompt, contains('[INST]'));
      expect(prompt, contains('Hello!'));
      expect(prompt, contains('[/INST]'));
    });

    test('includes system message in first user turn', () {
      final messages = [
        const ChatMessage.system('Be helpful.'),
        const ChatMessage.user('Hi'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('Be helpful.'));
      expect(prompt, contains('Hi'));
    });
  });

  group('Phi3Template', () {
    late Phi3Template template;

    setUp(() {
      template = Phi3Template();
    });

    test('has correct name', () {
      expect(template.name, equals('Phi3'));
    });

    test('uses pipe-bracket format', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<|system|>'));
      expect(prompt, contains('<|user|>'));
      expect(prompt, contains('<|assistant|>'));
      expect(prompt, contains('<|end|>'));
    });

    test('adds newlines after tags', () {
      final messages = [const ChatMessage.user('Hi')];
      final prompt = template.apply(messages);

      expect(prompt, contains('<|user|>\nHi'));
    });
  });

  group('GemmaInstructTemplate', () {
    late GemmaInstructTemplate template;

    setUp(() {
      template = GemmaInstructTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('GemmaInstruct'));
    });

    test('uses start_of_turn and end_of_turn', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<start_of_turn>'));
      expect(prompt, contains('<end_of_turn>'));
    });

    test('uses model role for assistant', () {
      final prompt = template.apply(testMessages);
      expect(prompt, contains('<start_of_turn>model'));
    });

    test('includes system in first user turn', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<start_of_turn>user'));
      expect(prompt, contains('You are a helpful assistant.'));
    });
  });

  group('AlpacaTemplate', () {
    late AlpacaTemplate template;

    setUp(() {
      template = AlpacaTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('Alpaca'));
    });

    test('uses ### Instruction: format', () {
      final messages = [const ChatMessage.user('Hi')];
      final prompt = template.apply(messages);

      expect(prompt, contains('### Instruction:'));
    });

    test('uses ### Response: format', () {
      final messages = [
        const ChatMessage.user('Hi'),
        const ChatMessage.assistant('Hello!'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('### Response:'));
    });

    test('uses system message as preamble', () {
      final prompt = template.apply(testMessages);
      expect(prompt, contains('You are a helpful assistant.'));
    });
  });

  group('VicunaTemplate', () {
    late VicunaTemplate template;

    setUp(() {
      template = VicunaTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('Vicuna'));
    });

    test('uses USER: and ASSISTANT: format', () {
      final messages = [
        const ChatMessage.user('Hi'),
        const ChatMessage.assistant('Hello!'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('USER:'));
      expect(prompt, contains('ASSISTANT:'));
    });

    test('ends assistant messages with </s>', () {
      final messages = [
        const ChatMessage.user('Hi'),
        const ChatMessage.assistant('Hello!'),
      ];
      final prompt = template.apply(messages);

      expect(prompt, contains('Hello!</s>'));
    });
  });

  group('CommandRTemplate', () {
    late CommandRTemplate template;

    setUp(() {
      template = CommandRTemplate();
    });

    test('has correct name', () {
      expect(template.name, equals('CommandR'));
    });

    test('uses TURN tokens', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<|START_OF_TURN_TOKEN|>'));
      expect(prompt, contains('<|END_OF_TURN_TOKEN|>'));
    });

    test('uses role tokens', () {
      final prompt = template.apply(testMessages);

      expect(prompt, contains('<|SYSTEM_TOKEN|>'));
      expect(prompt, contains('<|USER_TOKEN|>'));
      expect(prompt, contains('<|CHATBOT_TOKEN|>'));
    });
  });

  group('QwenChatTemplate', () {
    test('extends ChatMLTemplate', () {
      final template = QwenChatTemplate();
      expect(template, isA<ChatMLTemplate>());
    });

    test('has correct name', () {
      final template = QwenChatTemplate();
      expect(template.name, equals('QwenChat'));
    });
  });

  group('ChatTemplateFactory', () {
    group('forArchitecture', () {
      test('returns Llama3 template for llama-3 architecture', () {
        final template = ChatTemplateFactory.forArchitecture('llama-3');
        expect(template, isA<Llama3InstructTemplate>());
      });

      test('returns Llama2 template for llama-2 architecture', () {
        final template = ChatTemplateFactory.forArchitecture('llama-2-chat');
        expect(template, isA<Llama2ChatTemplate>());
      });

      test('returns Mistral template for mistral architecture', () {
        final template = ChatTemplateFactory.forArchitecture('mistral-7b');
        expect(template, isA<MistralInstructTemplate>());
      });

      test('returns Phi3 template for phi-3 architecture', () {
        final template = ChatTemplateFactory.forArchitecture('phi-3-mini');
        expect(template, isA<Phi3Template>());
      });

      test('returns Qwen template for qwen architecture', () {
        final template = ChatTemplateFactory.forArchitecture('qwen2.5-7b');
        expect(template, isA<QwenChatTemplate>());
      });

      test('returns Gemma template for gemma architecture', () {
        final template = ChatTemplateFactory.forArchitecture('gemma-2-9b');
        expect(template, isA<GemmaInstructTemplate>());
      });

      test('returns ChatML for unknown architecture', () {
        final template = ChatTemplateFactory.forArchitecture('unknown-model');
        expect(template, isA<ChatMLTemplate>());
        expect(template, isNot(isA<QwenChatTemplate>()));
      });

      test('is case insensitive', () {
        final template1 = ChatTemplateFactory.forArchitecture('LLAMA-3');
        final template2 = ChatTemplateFactory.forArchitecture('llama-3');
        expect(template1.runtimeType, equals(template2.runtimeType));
      });
    });

    group('byName', () {
      test('returns correct template by name', () {
        expect(ChatTemplateFactory.byName('chatml'), isA<ChatMLTemplate>());
        expect(ChatTemplateFactory.byName('llama2'), isA<Llama2ChatTemplate>());
        expect(ChatTemplateFactory.byName('llama3'), isA<Llama3InstructTemplate>());
        expect(ChatTemplateFactory.byName('mistral'), isA<MistralInstructTemplate>());
        expect(ChatTemplateFactory.byName('phi3'), isA<Phi3Template>());
        expect(ChatTemplateFactory.byName('gemma'), isA<GemmaInstructTemplate>());
        expect(ChatTemplateFactory.byName('alpaca'), isA<AlpacaTemplate>());
        expect(ChatTemplateFactory.byName('vicuna'), isA<VicunaTemplate>());
        expect(ChatTemplateFactory.byName('commandr'), isA<CommandRTemplate>());
      });

      test('returns null for unknown name', () {
        expect(ChatTemplateFactory.byName('unknown'), isNull);
      });

      test('is case insensitive', () {
        expect(ChatTemplateFactory.byName('CHATML'), isA<ChatMLTemplate>());
        expect(ChatTemplateFactory.byName('ChatML'), isA<ChatMLTemplate>());
      });
    });

    group('availableTemplates', () {
      test('lists all available templates', () {
        final templates = ChatTemplateFactory.availableTemplates;

        expect(templates, contains('ChatML'));
        expect(templates, contains('Llama2Chat'));
        expect(templates, contains('Llama3Instruct'));
        expect(templates, contains('MistralInstruct'));
        expect(templates, contains('Phi3'));
        expect(templates, contains('QwenChat'));
        expect(templates, contains('GemmaInstruct'));
        expect(templates, contains('Alpaca'));
        expect(templates, contains('Vicuna'));
        expect(templates, contains('CommandR'));
      });

      test('contains expected number of templates', () {
        expect(ChatTemplateFactory.availableTemplates.length, equals(10));
      });
    });
  });
}
