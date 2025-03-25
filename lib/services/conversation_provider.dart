import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';

class ConversationProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  String? _selectedConversationId;

  List<Conversation> get conversations => _conversations;

  Conversation? get selectedConversation {
    if (_selectedConversationId == null) {
      return null;
    }
    try {
      return _conversations.firstWhere(
        (conversation) => conversation.id == _selectedConversationId,
      );
    } catch (_) {
      return null;
    }
  }

  void createNewConversation() {
    final newConversation = Conversation(title: 'New Conversation');
    _conversations.add(newConversation);
    _selectedConversationId = newConversation.id;
    notifyListeners();
  }

  void selectConversation(String id) {
    _selectedConversationId = id;
    notifyListeners();
  }

  void deleteConversation(String id) {
    _conversations.removeWhere((conversation) => conversation.id == id);
    if (_selectedConversationId == id) {
      _selectedConversationId =
          _conversations.isNotEmpty ? _conversations.first.id : null;
    }
    notifyListeners();
  }

  void addMessageToSelectedConversation(String content, bool isUser) {
    if (_selectedConversationId == null) {
      return;
    }

    final message = Message(content: content, isUser: isUser);

    final conversationIndex = _conversations.indexWhere(
      (conversation) => conversation.id == _selectedConversationId,
    );

    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = [...conversation.messages, message];

      _conversations[conversationIndex] = conversation.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
    }
  }
}
