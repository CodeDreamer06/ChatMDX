import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';

class ConversationProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  String? _selectedConversationId;
  String _searchQuery = '';
  String? _error;
  final ApiService _apiService = ApiService();

  String get searchQuery => _searchQuery;
  String? get error => _error;

  List<Conversation> get conversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations
        .where(
          (conversation) => conversation.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

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

  Future<void> addMessageToSelectedConversation(
    String content,
    bool isUser,
  ) async {
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

      _error = null;
      notifyListeners();

      if (isUser) {
        try {
          final messages =
              updatedMessages
                  .map(
                    (msg) => {
                      'role': msg.isUser ? 'user' : 'assistant',
                      'content': msg.content,
                    },
                  )
                  .toList();

          // Create an initial empty message for streaming updates
          final assistantMessage = Message(content: '', isUser: false);

          _conversations[conversationIndex] = _conversations[conversationIndex]
              .copyWith(
                messages: [...updatedMessages, assistantMessage],
                updatedAt: DateTime.now(),
              );

          _error = null;
          notifyListeners();

          // Use the streaming API
          String fullResponse = '';
          await for (final chunk in _apiService.streamMessage(messages)) {
            fullResponse += chunk;

            // Update the message content incrementally
            final currentConversation = _conversations[conversationIndex];
            final currentMessages = List<Message>.from(
              currentConversation.messages,
            );
            currentMessages[currentMessages.length - 1] = Message(
              content: fullResponse,
              isUser: false,
            );

            _conversations[conversationIndex] = currentConversation.copyWith(
              messages: currentMessages,
              updatedAt: DateTime.now(),
            );

            _error = null;
            notifyListeners();
          }
        } catch (e) {
          _error = e.toString();
          notifyListeners();
        }
      }
    }
  }

  void renameConversation(String id, String newTitle) {
    final index = _conversations.indexWhere(
      (conversation) => conversation.id == id,
    );
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void navigateConversation(bool up) {
    if (_conversations.isEmpty) return;

    if (_selectedConversationId == null) {
      _selectedConversationId =
          up ? _conversations.last.id : _conversations.first.id;
      notifyListeners();
      return;
    }

    final currentIndex = _conversations.indexWhere(
      (conversation) => conversation.id == _selectedConversationId,
    );

    if (currentIndex == -1) return;

    int newIndex;
    if (up) {
      newIndex =
          currentIndex > 0 ? currentIndex - 1 : _conversations.length - 1;
    } else {
      newIndex =
          currentIndex < _conversations.length - 1 ? currentIndex + 1 : 0;
    }

    _selectedConversationId = _conversations[newIndex].id;
    notifyListeners();
  }
}
