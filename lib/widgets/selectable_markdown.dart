import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/dracula.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/shell.dart';

class SelectableMarkdown extends StatelessWidget {
  final String data;
  final MarkdownStyleSheet styleSheet;

  const SelectableMarkdown({
    super.key,
    required this.data,
    required this.styleSheet,
  });

  @override
  Widget build(BuildContext context) {
    // For proper selection, we'll use a SelectableText without any Stack tricks
    return MarkdownBody(
      data: data,
      selectable: true, // Enable selection
      styleSheet: styleSheet,
      builders: {
        'math': MathElementBuilder(),
        'inlineMath': InlineMathElementBuilder(),
        'code': CodeElementBuilder(),
      },
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
  }

  // Process content to handle LaTeX math delimiters
  static String processMathDelimiters(String content) {
    // Replace $$...$$ with math blocks
    final displayMathRegExp = RegExp(r'\$\$(.*?)\$\$', dotAll: true);
    content = content.replaceAllMapped(displayMathRegExp, (match) {
      return '\n\n<math>${match.group(1)}</math>\n\n';
    });

    // Replace $...$ with inline math blocks
    final inlineMathRegExp = RegExp(
      r'(?<!\$)\$(?!\$)(.*?)(?<!\$)\$(?!\$)',
      dotAll: true,
    );
    content = content.replaceAllMapped(inlineMathRegExp, (match) {
      return '<inlineMath>${match.group(1)}</inlineMath>';
    });

    return content;
  }
}

// Math element builder
class MathElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    final String texExpression = element.textContent.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectionContainer.disabled(
        child: Math.tex(
          texExpression,
          textStyle: style,
          mathStyle: MathStyle.display,
          onErrorFallback: (e) {
            debugPrint('Math error: $e');
            return Text(texExpression, style: style);
          },
        ),
      ),
    );
  }
}

// Inline math element builder
class InlineMathElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    final String texExpression = element.textContent.trim();

    return SelectionContainer.disabled(
      child: Math.tex(
        texExpression,
        textStyle: style,
        mathStyle: MathStyle.text,
        onErrorFallback: (e) {
          debugPrint('Inline math error: $e');
          return Text(texExpression, style: style);
        },
      ),
    );
  }
}

// Code element builder
class CodeElementBuilder extends MarkdownElementBuilder {
  // Map of languages supported by highlight.js
  static final Map<String, String> _languageMap = {
    'javascript': 'javascript',
    'js': 'javascript',
    'typescript': 'javascript', // Fallback to JavaScript highlighting
    'ts': 'javascript',
    'dart': 'dart',
    'python': 'python',
    'py': 'python',
    'c++': 'cpp',
    'cpp': 'cpp',
    'c': 'cpp',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yaml',
    'bash': 'shell',
    'sh': 'shell',
    'shell': 'shell',
  };

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    String language = '';
    final String code = element.textContent;

    // Try to extract language info
    if (element.attributes.containsKey('class')) {
      final String classAttr = element.attributes['class'] as String;
      if (classAttr.startsWith('language-')) {
        language = classAttr.substring(9);
      }
    }

    // Get the mapped language or fallback to plain text
    final String mappedLanguage = _languageMap[language.toLowerCase()] ?? '';

    return Builder(
      builder:
          (context) => Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (language.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final clipboardData = ClipboardData(text: code);
                            Clipboard.setData(clipboardData);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Use Highlighter with a dark theme for highlighting
                ClipRRect(
                  borderRadius:
                      language.isEmpty
                          ? BorderRadius.circular(8)
                          : BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:
                        mappedLanguage.isNotEmpty
                            ? HighlightView(
                              code,
                              language: mappedLanguage,
                              theme: draculaTheme,
                              textStyle: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                height: 1.5,
                              ),
                              padding: const EdgeInsets.all(16),
                            )
                            : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SelectableText(
                                code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
