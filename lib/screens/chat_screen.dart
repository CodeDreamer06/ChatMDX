import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../models/conversation.dart';
import '../widgets/sidebar.dart';
import '../widgets/chat_area.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      content: Row(
        children: [
          // Sidebar
          const SizedBox(width: 280, child: Sidebar()),

          // Vertical divider
          Container(
            width: 1,
            color:
                fluent.FluentTheme.of(context).brightness == Brightness.light
                    ? fluent.Colors.grey[30]
                    : fluent.Colors.grey[100],
          ),

          // Chat area and input
          Expanded(
            child: Column(
              children: [
                // Chat messages area
                const Expanded(child: ChatArea()),

                // Message input at the bottom
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: MessageInput(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
