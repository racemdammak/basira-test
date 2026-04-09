import 'package:flutter_dotenv/flutter_dotenv.dart';

String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
String get groqBaseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
String get geminiBaseUrl => dotenv.env['GEMINI_BASE_URL'] ?? 'https://generativelanguage.googleapis.com/v1beta';
String get modelName => dotenv.env['MODEL_NAME'] ?? 'gemini-1.0-pro';
double get modelTemperature => double.tryParse(dotenv.env['MODEL_TEMPERATURE'] ?? '0.7') ?? 0.7;
