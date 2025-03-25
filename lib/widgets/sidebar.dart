import 'package:flutter/material.dart';
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
          fluent.Divider(style: const fluent.DividerThemeData(thickness: 1)),
          Expanded(
            child:
                conversations.isEmpty
                    ? const Center(
                      child: Text(
                        'No conversations yet.\nCreate one to get started!',
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final isSelected =
                            selectedConversation?.id == conversation.id;

                        return fluent.HoverButton(
                          onPressed: () {
                            conversationProvider.selectConversation(
                              conversation.id,
                            );
                          },
                          builder: (context, states) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? fluent.FluentTheme.of(
                                          context,
                                        ).accentColor.withOpacity(0.1)
                                        : states.isHovering
                                        ? fluent.FluentTheme.of(
                                          context,
                                        ).cardColor.withOpacity(0.5)
                                        : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color:
                                        isSelected
                                            ? fluent.FluentTheme.of(
                                              context,
                                            ).accentColor
                                            : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(fluent.FluentIcons.chat),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      conversation.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  fluent.IconButton(
                                    icon: const Icon(fluent.FluentIcons.delete),
                                    onPressed: () {
                                      conversationProvider.deleteConversation(
                                        conversation.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
