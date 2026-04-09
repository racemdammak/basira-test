import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_keys.dart';

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class GeminiService {
  late final Dio _dio;
  final List<ChatMessage> _history = [];

  GeminiService() {
    _dio = Dio(BaseOptions(
      baseUrl: geminiBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiApiKey,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<String> sendMessage({
    required String userMessage,
    required String systemPrompt,
  }) async {
    _history.add(ChatMessage(role: 'user', content: userMessage));

    // For Gemini, we need to format the messages differently
    final contents = [
      {'parts': [{'text': systemPrompt}], 'role': 'user'},
      ..._history.map((msg) => {
        'parts': [{'text': msg.content}],
        'role': msg.role == 'assistant' ? 'model' : 'user',
      }),
    ];

    try {
      print('Sending request to Gemini API');
      print('Model: $modelName');
      print('Contents: $contents');
      final response = await _dio.post(
        '/models/${modelName}:generateContent',
        data: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': modelTemperature,
            'maxOutputTokens': 500,
          },
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      final data = response.data;
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'];
        final parts = content['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          final text = parts.first['text'] as String;
          _history.add(ChatMessage(role: 'assistant', content: text));
          return text;
        }
      }
      return 'Sorry, I could not generate a response. Please try again.';
    } catch (e, stackTrace) {
      print('GeminiService Error: $e');
      print('StackTrace: $stackTrace');
      return 'Sorry, I could not connect to the AI service. Please try again later.';
    }
  }

  List<ChatMessage> get history => List.unmodifiable(_history);

  void clearHistory() => _history.clear();
}