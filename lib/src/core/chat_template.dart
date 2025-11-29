import 'package:dartllm/src/models/chat_message.dart';

/// Abstract interface for formatting chat messages into model prompts.
///
/// Different models use different chat templates to structure conversations.
/// Each template implementation knows how to format system, user, and
/// assistant messages according to the model's expected format.
///
/// Usage:
/// ```dart
/// final template = ChatMLTemplate();
/// final prompt = template.apply(messages);
/// ```
abstract interface class ChatTemplate {
  /// The name of this template.
  String get name;

  /// Applies the template to format messages into a prompt string.
  ///
  /// [messages] is the list of chat messages to format.
  /// [addGenerationPrompt] whether to add the assistant turn prefix.
  ///
  /// Returns the formatted prompt string ready for tokenization.
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true});

  /// Extracts the assistant's response from generated text.
  ///
  /// [generatedText] is the raw text output from the model.
  ///
  /// Returns the cleaned assistant response.
  String extractResponse(String generatedText);

  /// Gets the stop sequences for this template.
  ///
  /// These sequences indicate the end of an assistant turn.
  List<String> get stopSequences;
}

/// ChatML template format.
///
/// Used by many fine-tuned models including OpenHermes, Dolphin, and others.
///
/// Format:
/// ```
/// <|im_start|>system
/// {system_message}<|im_end|>
/// <|im_start|>user
/// {user_message}<|im_end|>
/// <|im_start|>assistant
/// {assistant_message}<|im_end|>
/// ```
class ChatMLTemplate implements ChatTemplate {
  @override
  String get name => 'ChatML';

  @override
  List<String> get stopSequences => ['<|im_end|>', '<|im_start|>'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();

    for (final message in messages) {
      switch (message) {
        case SystemMessage(:final content):
          buffer.write('<|im_start|>system\n');
          buffer.write(content);
          buffer.write('<|im_end|>\n');

        case UserMessage(:final content):
          buffer.write('<|im_start|>user\n');
          buffer.write(content);
          buffer.write('<|im_end|>\n');

        case UserImageMessage(:final content):
          buffer.write('<|im_start|>user\n');
          buffer.write(content);
          buffer.write('<|im_end|>\n');

        case AssistantMessage(:final content):
          buffer.write('<|im_start|>assistant\n');
          buffer.write(content);
          buffer.write('<|im_end|>\n');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('<|im_start|>assistant\n');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Llama 2 Chat template format.
///
/// Format:
/// ```
/// [INST] <<SYS>>
/// {system_message}
/// <</SYS>>
///
/// {user_message} [/INST] {assistant_message} </s><s>[INST] ...
/// ```
class Llama2ChatTemplate implements ChatTemplate {
  @override
  String get name => 'Llama2Chat';

  @override
  List<String> get stopSequences => ['</s>', '[INST]'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    String? systemMessage;
    bool isFirstUser = true;

    // Extract system message if present
    for (final message in messages) {
      if (message is SystemMessage) {
        systemMessage = message.content;
        break;
      }
    }

    for (final message in messages) {
      switch (message) {
        case SystemMessage():
          continue; // Handled inline with first user message

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('<s>[INST] ');
          if (isFirstUser && systemMessage != null) {
            buffer.write('<<SYS>>\n');
            buffer.write(systemMessage);
            buffer.write('\n<</SYS>>\n\n');
          }
          buffer.write(content);
          buffer.write(' [/INST]');
          isFirstUser = false;

        case AssistantMessage(:final content):
          buffer.write(' ');
          buffer.write(content);
          buffer.write(' </s>');
      }
    }

    if (addGenerationPrompt) {
      buffer.write(' ');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Llama 3 Instruct template format.
///
/// Format:
/// ```
/// <|begin_of_text|><|start_header_id|>system<|end_header_id|>
/// {system_message}<|eot_id|><|start_header_id|>user<|end_header_id|>
/// {user_message}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
/// ```
class Llama3InstructTemplate implements ChatTemplate {
  @override
  String get name => 'Llama3Instruct';

  @override
  List<String> get stopSequences => ['<|eot_id|>', '<|end_of_text|>'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    buffer.write('<|begin_of_text|>');

    for (final message in messages) {
      switch (message) {
        case SystemMessage(:final content):
          buffer.write('<|start_header_id|>system<|end_header_id|>\n\n');
          buffer.write(content);
          buffer.write('<|eot_id|>');

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('<|start_header_id|>user<|end_header_id|>\n\n');
          buffer.write(content);
          buffer.write('<|eot_id|>');

        case AssistantMessage(:final content):
          buffer.write('<|start_header_id|>assistant<|end_header_id|>\n\n');
          buffer.write(content);
          buffer.write('<|eot_id|>');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('<|start_header_id|>assistant<|end_header_id|>\n\n');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Mistral Instruct template format.
///
/// Format:
/// ```
/// <s>[INST] {system_message}
///
/// {user_message} [/INST] {assistant_message}</s>[INST] ...
/// ```
class MistralInstructTemplate implements ChatTemplate {
  @override
  String get name => 'MistralInstruct';

  @override
  List<String> get stopSequences => ['</s>', '[INST]'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    String? systemMessage;
    bool isFirstUser = true;

    for (final message in messages) {
      if (message is SystemMessage) {
        systemMessage = message.content;
        break;
      }
    }

    buffer.write('<s>');

    for (final message in messages) {
      switch (message) {
        case SystemMessage():
          continue;

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('[INST] ');
          if (isFirstUser && systemMessage != null) {
            buffer.write(systemMessage);
            buffer.write('\n\n');
          }
          buffer.write(content);
          buffer.write(' [/INST]');
          isFirstUser = false;

        case AssistantMessage(:final content):
          buffer.write(content);
          buffer.write('</s>');
      }
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Phi-3 template format.
///
/// Format:
/// ```
/// <|system|>
/// {system_message}<|end|>
/// <|user|>
/// {user_message}<|end|>
/// <|assistant|>
/// {assistant_message}<|end|>
/// ```
class Phi3Template implements ChatTemplate {
  @override
  String get name => 'Phi3';

  @override
  List<String> get stopSequences => ['<|end|>', '<|user|>', '<|assistant|>'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();

    for (final message in messages) {
      switch (message) {
        case SystemMessage(:final content):
          buffer.write('<|system|>\n');
          buffer.write(content);
          buffer.write('<|end|>\n');

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('<|user|>\n');
          buffer.write(content);
          buffer.write('<|end|>\n');

        case AssistantMessage(:final content):
          buffer.write('<|assistant|>\n');
          buffer.write(content);
          buffer.write('<|end|>\n');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('<|assistant|>\n');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Qwen Chat template format.
///
/// Format:
/// ```
/// <|im_start|>system
/// {system_message}<|im_end|>
/// <|im_start|>user
/// {user_message}<|im_end|>
/// <|im_start|>assistant
/// {assistant_message}<|im_end|>
/// ```
///
/// Note: Qwen uses the same format as ChatML.
class QwenChatTemplate extends ChatMLTemplate {
  @override
  String get name => 'QwenChat';
}

/// Gemma Instruct template format.
///
/// Format:
/// ```
/// <start_of_turn>user
/// {user_message}<end_of_turn>
/// <start_of_turn>model
/// {assistant_message}<end_of_turn>
/// ```
class GemmaInstructTemplate implements ChatTemplate {
  @override
  String get name => 'GemmaInstruct';

  @override
  List<String> get stopSequences => ['<end_of_turn>', '<start_of_turn>'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    String? systemMessage;

    for (final message in messages) {
      if (message is SystemMessage) {
        systemMessage = message.content;
        break;
      }
    }

    bool isFirstUser = true;

    for (final message in messages) {
      switch (message) {
        case SystemMessage():
          continue;

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('<start_of_turn>user\n');
          if (isFirstUser && systemMessage != null) {
            buffer.write(systemMessage);
            buffer.write('\n\n');
          }
          buffer.write(content);
          buffer.write('<end_of_turn>\n');
          isFirstUser = false;

        case AssistantMessage(:final content):
          buffer.write('<start_of_turn>model\n');
          buffer.write(content);
          buffer.write('<end_of_turn>\n');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('<start_of_turn>model\n');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Alpaca template format.
///
/// Format:
/// ```
/// Below is an instruction that describes a task. Write a response that
/// appropriately completes the request.
///
/// ### Instruction:
/// {user_message}
///
/// ### Response:
/// {assistant_message}
/// ```
class AlpacaTemplate implements ChatTemplate {
  @override
  String get name => 'Alpaca';

  @override
  List<String> get stopSequences => ['### Instruction:', '###'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    String? systemMessage;

    for (final message in messages) {
      if (message is SystemMessage) {
        systemMessage = message.content;
        break;
      }
    }

    buffer.write(systemMessage ??
        'Below is an instruction that describes a task. '
            'Write a response that appropriately completes the request.');
    buffer.write('\n\n');

    for (final message in messages) {
      switch (message) {
        case SystemMessage():
          continue;

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('### Instruction:\n');
          buffer.write(content);
          buffer.write('\n\n');

        case AssistantMessage(:final content):
          buffer.write('### Response:\n');
          buffer.write(content);
          buffer.write('\n\n');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('### Response:\n');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Vicuna template format.
///
/// Format:
/// ```
/// {system_message}
///
/// USER: {user_message}
/// ASSISTANT: {assistant_message}</s>
/// USER: ...
/// ```
class VicunaTemplate implements ChatTemplate {
  @override
  String get name => 'Vicuna';

  @override
  List<String> get stopSequences => ['</s>', 'USER:'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();
    String? systemMessage;

    for (final message in messages) {
      if (message is SystemMessage) {
        systemMessage = message.content;
        break;
      }
    }

    if (systemMessage != null) {
      buffer.write(systemMessage);
      buffer.write('\n\n');
    }

    for (final message in messages) {
      switch (message) {
        case SystemMessage():
          continue;

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('USER: ');
          buffer.write(content);
          buffer.write('\n');

        case AssistantMessage(:final content):
          buffer.write('ASSISTANT: ');
          buffer.write(content);
          buffer.write('</s>\n');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('ASSISTANT:');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Command R template format.
///
/// Format:
/// ```
/// <|START_OF_TURN_TOKEN|><|SYSTEM_TOKEN|>{system_message}<|END_OF_TURN_TOKEN|>
/// <|START_OF_TURN_TOKEN|><|USER_TOKEN|>{user_message}<|END_OF_TURN_TOKEN|>
/// <|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|>{assistant_message}<|END_OF_TURN_TOKEN|>
/// ```
class CommandRTemplate implements ChatTemplate {
  @override
  String get name => 'CommandR';

  @override
  List<String> get stopSequences =>
      ['<|END_OF_TURN_TOKEN|>', '<|START_OF_TURN_TOKEN|>'];

  @override
  String apply(List<ChatMessage> messages, {bool addGenerationPrompt = true}) {
    final buffer = StringBuffer();

    for (final message in messages) {
      switch (message) {
        case SystemMessage(:final content):
          buffer.write('<|START_OF_TURN_TOKEN|><|SYSTEM_TOKEN|>');
          buffer.write(content);
          buffer.write('<|END_OF_TURN_TOKEN|>');

        case UserMessage(:final content):
        case UserImageMessage(:final content):
          buffer.write('<|START_OF_TURN_TOKEN|><|USER_TOKEN|>');
          buffer.write(content);
          buffer.write('<|END_OF_TURN_TOKEN|>');

        case AssistantMessage(:final content):
          buffer.write('<|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|>');
          buffer.write(content);
          buffer.write('<|END_OF_TURN_TOKEN|>');
      }
    }

    if (addGenerationPrompt) {
      buffer.write('<|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|>');
    }

    return buffer.toString();
  }

  @override
  String extractResponse(String generatedText) {
    var response = generatedText;
    for (final stop in stopSequences) {
      final index = response.indexOf(stop);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }
    return response.trim();
  }
}

/// Factory for creating chat templates based on model architecture.
///
/// Automatically selects the appropriate template based on model
/// metadata or architecture string.
abstract final class ChatTemplateFactory {
  /// Creates a chat template for the given model architecture.
  ///
  /// [architecture] is the model architecture string from metadata.
  ///
  /// Returns the appropriate template, defaulting to ChatML if unknown.
  static ChatTemplate forArchitecture(String architecture) {
    final lower = architecture.toLowerCase();

    if (lower.contains('llama-3') || lower.contains('llama3')) {
      return Llama3InstructTemplate();
    }

    if (lower.contains('llama-2') || lower.contains('llama2')) {
      return Llama2ChatTemplate();
    }

    if (lower.contains('mistral') || lower.contains('mixtral')) {
      return MistralInstructTemplate();
    }

    if (lower.contains('phi-3') || lower.contains('phi3')) {
      return Phi3Template();
    }

    if (lower.contains('qwen')) {
      return QwenChatTemplate();
    }

    if (lower.contains('gemma')) {
      return GemmaInstructTemplate();
    }

    if (lower.contains('command')) {
      return CommandRTemplate();
    }

    if (lower.contains('vicuna')) {
      return VicunaTemplate();
    }

    if (lower.contains('alpaca')) {
      return AlpacaTemplate();
    }

    // Default to ChatML as it's widely supported
    return ChatMLTemplate();
  }

  /// Gets a template by name.
  ///
  /// [name] is the template name (case-insensitive).
  ///
  /// Returns the template or null if not found.
  static ChatTemplate? byName(String name) {
    final lower = name.toLowerCase();

    return switch (lower) {
      'chatml' => ChatMLTemplate(),
      'llama2' || 'llama2chat' => Llama2ChatTemplate(),
      'llama3' || 'llama3instruct' => Llama3InstructTemplate(),
      'mistral' || 'mistralinstruct' => MistralInstructTemplate(),
      'phi3' => Phi3Template(),
      'qwen' || 'qwenchat' => QwenChatTemplate(),
      'gemma' || 'gemmainstruct' => GemmaInstructTemplate(),
      'alpaca' => AlpacaTemplate(),
      'vicuna' => VicunaTemplate(),
      'commandr' => CommandRTemplate(),
      _ => null,
    };
  }

  /// Lists all available template names.
  static List<String> get availableTemplates => [
        'ChatML',
        'Llama2Chat',
        'Llama3Instruct',
        'MistralInstruct',
        'Phi3',
        'QwenChat',
        'GemmaInstruct',
        'Alpaca',
        'Vicuna',
        'CommandR',
      ];
}
