import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/conversation_provider.dart';
import 'services/keyboard_actions.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConversationProvider(),
      child: fluent.FluentApp(
        title: 'ChatMDX',
        debugShowCheckedModeBanner: false,
        theme: fluent.FluentThemeData(
          accentColor: fluent.Colors.blue,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: fluent.FluentThemeData(
          accentColor: fluent.Colors.blue,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const KeyboardShortcutsWrapper(child: ChatScreen()),
      ),
    );
  }
}

class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardShortcutsWrapper({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversationProvider = Provider.of<ConversationProvider>(
      context,
      listen: false,
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          control: true,
        ): NavigateConversationIntent(true),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          control: true,
        ): NavigateConversationIntent(false),
        SingleActivator(LogicalKeyboardKey.keyN, control: true):
            CreateConversationIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NavigateConversationIntent: NavigateConversationAction(
            conversationProvider,
          ),
          CreateConversationIntent: CreateConversationAction(
            conversationProvider,
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
