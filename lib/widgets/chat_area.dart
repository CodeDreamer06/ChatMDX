import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../models/conversation.dart';

class ChatArea extends StatelessWidget {
  const ChatArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final selectedConversation = conversationProvider.selectedConversation;

    if (selectedConversation == null) {
      return const Center(
        child: Text(
          'Select a conversation or create a new one',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (selectedConversation.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fluent.Icon(fluent.FluentIcons.chat, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Start a new conversation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type a message below to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: selectedConversation.messages.length,
      itemBuilder: (context, index) {
        final message = selectedConversation.messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: fluent.Icon(
                fluent.FluentIcons.robot,
                size: 24,
                color: fluent.FluentTheme.of(context).accentColor,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? fluent.FluentTheme.of(
                          context,
                        ).accentColor.withOpacity(0.1)
                        : fluent.FluentTheme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color:
                      message.isUser
                          ? fluent.FluentTheme.of(
                            context,
                          ).accentColor.withOpacity(0.2)
                          : fluent.Colors.grey[40]!,
                  width: 1,
                ),
              ),
              child: Text(
                message.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: fluent.Icon(
                fluent.FluentIcons.contact,
                size: 24,
                color: fluent.FluentTheme.of(context).accentColor,
              ),
            ),
        ],
      ),
    );
  }
}
