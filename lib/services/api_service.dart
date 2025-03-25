import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://meow.cablyai.com/v1';
  static const String _model = 'gemini-2.0-flash';
  static const double _temperature = 0.7;
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    int retryCount = 0;
    Exception? lastError;

    while (retryCount < _maxRetries) {
      try {
        print(
          'Sending message to API (attempt ${retryCount + 1}/$_maxRetries): $messages',
        );
        print('Using API key: ${dotenv.env['CABLY_API_KEY']}');

        final response = await http
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Authorization': 'Bearer ${dotenv.env['CABLY_API_KEY']}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'messages': messages,
                'model': _model,
                'temperature': _temperature,
              }),
            )
            .timeout(_timeout);

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'];
        } else {
          lastError = _handleError(response.statusCode, response.body);
        }
      } catch (e) {
        print(
          'Error sending message (attempt ${retryCount + 1}/$_maxRetries): $e',
        );
        lastError = _handleError(0, e.toString());
      }

      retryCount++;
      if (retryCount < _maxRetries) {
        // Exponential backoff: wait longer between each retry
        await Future.delayed(Duration(seconds: 1 << retryCount));
      }
    }

    throw lastError ??
        Exception('Failed to send message after $_maxRetries attempts');
  }

  Stream<String> streamMessage(List<Map<String, String>> messages) async* {
    int retryCount = 0;
    Exception? lastError;

    while (retryCount < _maxRetries) {
      try {
        print(
          'Streaming message from API (attempt ${retryCount + 1}/$_maxRetries): $messages',
        );
        print('Using API key: ${dotenv.env['CABLY_API_KEY']}');

        final client = http.Client();
        final request = http.Request(
          'POST',
          Uri.parse('$_baseUrl/chat/completions'),
        );
        request.headers.addAll({
          'Authorization': 'Bearer ${dotenv.env['CABLY_API_KEY']}',
          'Content-Type': 'application/json',
        });
        request.body = jsonEncode({
          'messages': messages,
          'model': _model,
          'temperature': _temperature,
          'stream': true,
        });

        final streamedResponse = await client.send(request).timeout(_timeout);

        if (streamedResponse.statusCode == 200) {
          final stream = streamedResponse.stream.transform(utf8.decoder);

          await for (var chunk in stream) {
            // Skip empty chunks and control characters
            if (chunk.trim().isEmpty) continue;

            // Handle server-sent events format
            for (var line in chunk.split('\n')) {
              line = line.trim();

              // Skip empty lines or "data: [DONE]"
              if (line.isEmpty || line == 'data: [DONE]') continue;

              // Extract the data part
              if (line.startsWith('data: ')) {
                final data = line.substring(6);
                try {
                  final jsonData = jsonDecode(data);
                  final content = jsonData['choices'][0]['delta']['content'];
                  if (content != null && content.isNotEmpty) {
                    yield content;
                  }
                } catch (e) {
                  print('Error parsing JSON: $e for line: $line');
                }
              }
            }
          }

          client.close();
          return; // Successfully completed
        } else {
          final responseBody = await streamedResponse.stream.bytesToString();
          print('Error status code: ${streamedResponse.statusCode}');
          print('Error response: $responseBody');
          lastError = _handleError(streamedResponse.statusCode, responseBody);
          client.close();
        }
      } catch (e) {
        print(
          'Error streaming message (attempt ${retryCount + 1}/$_maxRetries): $e',
        );
        lastError = _handleError(0, e.toString());
      }

      retryCount++;
      if (retryCount < _maxRetries) {
        // Exponential backoff: wait longer between each retry
        await Future.delayed(Duration(seconds: 1 << retryCount));
      }
    }

    throw lastError ??
        Exception('Failed to stream message after $_maxRetries attempts');
  }

  Exception _handleError(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return Exception('Invalid API key. Please check your .env file.');
      case 429:
        return Exception('Rate limit exceeded. Please try again later.');
      case 500:
        return Exception('Server error. Please try again later.');
      case 503:
        return Exception('Service unavailable. Please try again later.');
      default:
        if (body.contains('timeout') || body.contains('semaphore')) {
          return Exception(
            'Connection timeout. Please check your internet connection and try again.',
          );
        }
        return Exception('Error: $body');
    }
  }
}
