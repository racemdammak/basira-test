import 'package:flutter_dotenv/flutter_dotenv.dart';

String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
const baseUrl = 'https://openrouter.ai/api/v1';
String get modelName => dotenv.env['MODEL_NAME'] ?? 'meta-llama/llama-3.1-8b-instruct';
double get modelTemperature => double.tryParse(dotenv.env['MODEL_TEMPERATURE'] ?? '0.7') ?? 0.7;
