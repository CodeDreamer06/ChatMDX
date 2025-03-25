import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../models/conversation.dart';
import 'selectable_markdown.dart';

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

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Column(
          crossAxisAlignment:
              widget.message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              margin: const EdgeInsets.only(
                bottom: 4,
              ), // Reduced margin to accommodate buttons
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.message.isUser ? Colors.blue : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  widget.message.isUser
                      // User message content
                      ? SelectableText(
                        widget.message.content,
                        style: const TextStyle(color: Colors.white),
                      )
                      // Assistant message content
                      : Builder(
                        builder: (context) {
                          // Pre-process content to handle LaTeX math between $...$ delimiters
                          String processedContent =
                              SelectableMarkdown.processMathDelimiters(
                                widget.message.content,
                              );

                          return SelectableMarkdown(
                            data: processedContent,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              h1: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
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
                              a: const TextStyle(color: Colors.lightBlue),
                              blockquote: const TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Action buttons below the message bubble
            if (widget.message.isUser)
              SizedBox(
                height: 28, // Fixed height to reserve space
                child: AnimatedOpacity(
                  opacity: _isHovering ? 1.0 : 0.0,
                  duration: const Duration(
                    milliseconds: 150,
                  ), // Fast fade animation
                  curve: Curves.easeInOut,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap:
                              _isHovering
                                  ? () {
                                    // Edit functionality to be implemented later
                                  }
                                  : null,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Copy button
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap:
                              _isHovering
                                  ? () {
                                    final clipboardData = ClipboardData(
                                      text: widget.message.content,
                                    );
                                    Clipboard.setData(clipboardData);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Message copied to clipboard',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                  : null,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Copy button for assistant messages
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Left-aligned
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          final clipboardData = ClipboardData(
                            text: widget.message.content,
                          );
                          Clipboard.setData(clipboardData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Markdown copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.copy, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Copy markdown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Spacing after the entire message component
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
