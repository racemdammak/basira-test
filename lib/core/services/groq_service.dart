import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_keys.dart';

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class GroqService {
  late final Dio _dio;
  final List<ChatMessage> _history = [];

  GroqService() {
    _dio = Dio(BaseOptions(
      baseUrl: groqBaseUrl,
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
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

    final messages = [
      ChatMessage(role: 'system', content: systemPrompt),
      ..._history,
    ];

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': modelName,
          'messages': messages.map((m) => m.toJson()).toList(),
          'max_tokens': 500,
          'temperature': modelTemperature,
        }),
      );

      final data = response.data;
      final assistantMsg =
          (data['choices'] as List).first['message']['content'] as String;
      _history.add(ChatMessage(role: 'assistant', content: assistantMsg));
      return assistantMsg;
    } catch (e, stackTrace) {
      // Log the error for debugging (in production, you might use a logging service)
      print('GroqService Error: $e');
      print('StackTrace: $stackTrace');
      return 'Sorry, I could not connect to the AI service. Please try again later.';
    }
  }

  List<ChatMessage> get history => List.unmodifiable(_history);

  void clearHistory() => _history.clear();
}
