import 'package:flutter/material.dart';
import 'package:dartllm/dartllm.dart';

void main() {
  runApp(const DartLLMExampleApp());
}

class DartLLMExampleApp extends StatelessWidget {
  const DartLLMExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DartLLM Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Widget> _chatWidgets = [];

  LLMModel? _model;
  bool _isLoading = false;
  bool _isGenerating = false;
  String _status = 'Model not loaded';
  double _loadProgress = 0;

  @override
  void dispose() {
    _controller.dispose();
    _model?.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading model...';
    });

    try {
      final model = await DartLLM.loadFromHuggingFace(
        'Qwen/Qwen2.5-0.5B-Instruct-GGUF',
        filename: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
        config: const ModelConfig(contextSize: 2048, gpuLayers: -1),
        onDownloadProgress: (progress) {
          setState(() {
            _loadProgress = progress;
            _status = 'Downloading: ${(progress * 100).toInt()}%';
          });
        },
      );

      setState(() {
        _model = model;
        _isLoading = false;
        _status = 'Model loaded: ${model.modelInfo.name}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_model == null || _controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(UserMessage(userText));
      _chatWidgets.add(_buildMessageWidget(userText, isUser: true));
      _isGenerating = true;
    });

    try {
      String response = '';

      await for (final chunk in _model!.chatStream(
        _messages,
        config: const GenerationConfig(maxTokens: 256),
      )) {
        final content = chunk.delta.content;
        response += content;
        setState(() {});
      }

      setState(() {
        _messages.add(AssistantMessage(response));
        _chatWidgets.add(_buildMessageWidget(response, isUser: false));
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _chatWidgets.add(_buildMessageWidget('Error: $e', isUser: false));
        _isGenerating = false;
      });
    }
  }

  Widget _buildMessageWidget(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DartLLM Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_model == null && !_isLoading)
            TextButton.icon(
              onPressed: _loadModel,
              icon: const Icon(Icons.download),
              label: const Text('Load Model'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: _loadProgress > 0 ? _loadProgress : null,
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_status, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _model == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('No model loaded'),
                        const SizedBox(height: 8),
                        if (!_isLoading)
                          ElevatedButton.icon(
                            onPressed: _loadModel,
                            icon: const Icon(Icons.download),
                            label: const Text('Download & Load Model'),
                          ),
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: LinearProgressIndicator(
                              value: _loadProgress > 0 ? _loadProgress : null,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _chatWidgets.length,
                    itemBuilder: (context, index) => _chatWidgets[index],
                  ),
          ),
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    enabled: _model != null && !_isGenerating,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _model != null && !_isGenerating
                      ? _sendMessage
                      : null,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
