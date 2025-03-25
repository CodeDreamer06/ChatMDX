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
  bool _isEditing = false;
  late TextEditingController _editController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      // Cancel edit when focus is lost
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editController.text = widget.message.content;
    });
    // Request focus after state has been updated
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  void _confirmEdit() {
    if (_editController.text.trim().isNotEmpty) {
      // Call the provider to edit message and remove subsequent messages
      Provider.of<ConversationProvider>(
        context,
        listen: false,
      ).editUserMessage(widget.message, _editController.text.trim());
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserMessage = widget.message.isUser;

    // Build the message content
    Widget messageContent;
    if (_isEditing && isUserMessage) {
      messageContent = TextField(
        controller: _editController,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: null,
        style: TextStyle(
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: (_) => _confirmEdit(),
      );
    } else {
      final StyleSheet = MarkdownStyleSheet(
        p: TextStyle(
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 14,
        ),
        h1: TextStyle(
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        code: TextStyle(
          backgroundColor: Colors.grey[800],
          color: isUserMessage ? Colors.white : theme.colorScheme.onSurface,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        a: const TextStyle(color: Colors.lightBlue),
        blockquote: TextStyle(
          color:
              isUserMessage
                  ? Colors.white70
                  : theme.colorScheme.onSurface.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.grey[700]!),
        ),
      );

      // Pre-process content to handle LaTeX math between $...$ delimiters
      String processedContent = SelectableMarkdown.processMathDelimiters(
        widget.message.content,
      );

      messageContent = SelectableMarkdown(
        data: processedContent,
        styleSheet: StyleSheet,
      );
    }

    // Show user message edit/confirm buttons when editing
    List<Widget> actionButtonsList;
    if (isUserMessage && _isEditing) {
      actionButtonsList = [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _confirmEdit,
            customBorder: CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check, size: 20, color: Colors.green),
            ),
          ),
        ),
      ];
    } else if (isUserMessage) {
      actionButtonsList = [
        // Edit button
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _startEditing,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.edit, size: 16, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Copy button
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              final clipboardData = ClipboardData(text: widget.message.content);
              Clipboard.setData(clipboardData);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.copy, size: 16, color: Colors.grey),
            ),
          ),
        ),
      ];
    } else {
      // Assistant message copy button - only show if content is not empty
      actionButtonsList =
          widget.message.content.isEmpty
              ? [] // Empty list when message is still loading
              : [
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
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
    }

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
              child: messageContent,
            ),

            // Action buttons below the message bubble
            if (widget.message.isUser)
              SizedBox(
                height: 28, // Fixed height to reserve space
                child: AnimatedOpacity(
                  opacity: _isEditing || _isHovering ? 1.0 : 0.0,
                  duration: const Duration(
                    milliseconds: 150,
                  ), // Fast fade animation
                  curve: Curves.easeInOut,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actionButtonsList,
                  ),
                ),
              )
            else
              // Copy button for assistant messages
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Left-aligned
                  children: actionButtonsList,
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
