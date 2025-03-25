import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

// Custom syntax for LaTeX math
class MathSyntax extends md.InlineSyntax {
  MathSyntax() : super(r'(?:\$\$(.*?)\$\$|\$(.*?)\$)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final content = match.group(1) ?? match.group(2) ?? '';
    final element = md.Element('math', [md.Text(content)]);
    parser.addNode(element);
    return true;
  }
}

// Custom builder for math elements
class MathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    // Extract the LaTeX expression
    final text = element.textContent;

    // Determine if it's inline or display math
    final isDisplay = element.textContent.contains('\n');

    return Math.tex(
      text,
      textStyle: style,
      mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
      onErrorFallback: (FlutterMathException e) {
        debugPrint('Math parse error: $e');
        return Text(text, style: style);
      },
    );
  }
}

// Custom code block builder to handle code syntax highlighting
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? style) {
    String language = '';
    String code = element.textContent;

    // Try to extract language info from the first line
    if (element.attributes.containsKey('class')) {
      final String classAttr = element.attributes['class'] as String;
      if (classAttr.startsWith('language-')) {
        language = classAttr.substring(9);
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                language,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SelectableText(
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for creating our custom markdown extension set
class CustomMarkdownExtensionSet {
  static md.ExtensionSet get mathExtensionSet {
    final List<md.BlockSyntax> blockSyntaxes =
        md.ExtensionSet.gitHubFlavored.blockSyntaxes;
    final List<md.InlineSyntax> inlineSyntaxes = List.from(
      md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    )..add(MathSyntax());

    return md.ExtensionSet(blockSyntaxes, inlineSyntaxes);
  }
}
