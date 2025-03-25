import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'conversation_provider.dart';

class NavigateConversationIntent extends Intent {
  const NavigateConversationIntent(this.up);
  final bool up;
}

class CreateConversationIntent extends Intent {
  const CreateConversationIntent();
}

class NavigateConversationAction extends Action<NavigateConversationIntent> {
  NavigateConversationAction(this.provider);

  final ConversationProvider provider;

  @override
  void invoke(covariant NavigateConversationIntent intent) {
    provider.navigateConversation(intent.up);
  }
}

class CreateConversationAction extends Action<CreateConversationIntent> {
  CreateConversationAction(this.provider);

  final ConversationProvider provider;

  @override
  void invoke(covariant CreateConversationIntent intent) {
    provider.createNewConversation();
  }
}
