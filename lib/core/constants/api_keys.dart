import 'package:flutter_dotenv/flutter_dotenv.dart';

String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
String get groqBaseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
String get modelName => dotenv.env['MODEL_NAME'] ?? 'llama3-8b-8192';
double get modelTemperature => double.tryParse(dotenv.env['MODEL_TEMPERATURE'] ?? '0.7') ?? 0.7;
