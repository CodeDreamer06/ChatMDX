import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({Key? key}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      _isComposing = false;
    });

    // Add the user message and send it to the API
    final conversationProvider = Provider.of<ConversationProvider>(
      context,
      listen: false,
    );
    conversationProvider.addMessageToSelectedConversation(text, true);
  }

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final isConversationSelected =
        conversationProvider.selectedConversation != null;

    return fluent.Card(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: fluent.TextBox(
              controller: _controller,
              enabled: isConversationSelected,
              placeholder:
                  isConversationSelected
                      ? 'Type a message...'
                      : 'Select a conversation to start chatting',
              onChanged: (text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
              suffix: fluent.IconButton(
                icon: const Icon(fluent.FluentIcons.send),
                onPressed:
                    !_isComposing || !isConversationSelected
                        ? null
                        : () => _handleSubmitted(_controller.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
