import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../models/conversation.dart';

class ChatArea extends StatelessWidget {
  const ChatArea({super.key});

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final selectedConversation = conversationProvider.selectedConversation;
    final error = conversationProvider.error;

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
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: false,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: selectedConversation.messages.length,
            itemBuilder: (context, index) {
              final message = selectedConversation.messages[index];
              return MessageBubble(message: message);
            },
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            message.isUser
                ? Text(
                  message.content,
                  style: const TextStyle(color: Colors.white),
                )
                : MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Colors.white, fontSize: 14),
                    h1: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    h3: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    code: TextStyle(
                      backgroundColor: Colors.grey[800],
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  builders: {'math': SimpleMathBuilder()},
                  extensionSet: md.ExtensionSet.gitHubWeb,
                ),
      ),
    );
  }
}

// A simplified math builder that can handle basic math expressions
class SimpleMathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    final String texExpression = element.textContent.replaceAll(r'\$', '');

    return Math.tex(
      texExpression,
      textStyle: style,
      onErrorFallback: (e) => Text(texExpression),
    );
  }
}
