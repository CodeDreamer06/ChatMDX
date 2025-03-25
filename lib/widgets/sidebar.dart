import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../models/conversation.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final conversations = conversationProvider.conversations;
    final selectedConversation = conversationProvider.selectedConversation;

    return fluent.Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ChatMDX',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.add),
                  onPressed: () {
                    conversationProvider.createNewConversation();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: fluent.TextBox(
              placeholder: 'Search conversations...',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(fluent.FluentIcons.search),
              ),
              onChanged: (value) {
                conversationProvider.updateSearchQuery(value);
              },
            ),
          ),
          fluent.Divider(style: const fluent.DividerThemeData(thickness: 1)),
          Expanded(
            child:
                conversations.isEmpty
                    ? Center(
                      child: Text(
                        conversationProvider.searchQuery.isNotEmpty
                            ? 'No conversations found matching "${conversationProvider.searchQuery}"'
                            : 'No conversations yet.\nCreate one to get started!',
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final isSelected =
                            selectedConversation?.id == conversation.id;

                        return ConversationListItem(
                          conversation: conversation,
                          isSelected: isSelected,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class ConversationListItem extends StatefulWidget {
  final Conversation conversation;
  final bool isSelected;

  const ConversationListItem({
    Key? key,
    required this.conversation,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<ConversationListItem> createState() => _ConversationListItemState();
}

class _ConversationListItemState extends State<ConversationListItem> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.conversation.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRename() {
    if (_controller.text.trim().isNotEmpty) {
      final provider = Provider.of<ConversationProvider>(
        context,
        listen: false,
      );
      provider.renameConversation(
        widget.conversation.id,
        _controller.text.trim(),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.conversation.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(
      context,
      listen: false,
    );

    return fluent.HoverButton(
      onPressed: () {
        if (!_isEditing) {
          conversationProvider.selectConversation(widget.conversation.id);
        }
      },
      builder: (context, states) {
        return Container(
          decoration: BoxDecoration(
            color:
                widget.isSelected
                    ? fluent.FluentTheme.of(
                      context,
                    ).accentColor.withOpacity(0.1)
                    : states.isHovering
                    ? fluent.FluentTheme.of(context).cardColor.withOpacity(0.5)
                    : Colors.transparent,
            border: Border(
              left: BorderSide(
                color:
                    widget.isSelected
                        ? fluent.FluentTheme.of(context).accentColor
                        : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.chat),
              const SizedBox(width: 12),
              if (_isEditing)
                Expanded(
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.escape) {
                        _cancelEditing();
                      }
                    },
                    child: fluent.TextBox(
                      controller: _controller,
                      autofocus: true,
                      onSubmitted: (_) => _handleRename(),
                      onTapOutside: (_) => _cancelEditing(),
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          fluent.IconButton(
                            icon: const Icon(fluent.FluentIcons.cancel),
                            onPressed: _cancelEditing,
                          ),
                          fluent.IconButton(
                            icon: const Icon(fluent.FluentIcons.accept),
                            onPressed: _handleRename,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    widget.conversation.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (!_isEditing) ...[
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.delete),
                  onPressed: () {
                    conversationProvider.deleteConversation(
                      widget.conversation.id,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
