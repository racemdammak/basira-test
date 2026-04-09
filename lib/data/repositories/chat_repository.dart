import '../../core/services/gemini_service.dart';
import 'bus_repository.dart';

class ChatRepository {
  final GeminiService _service = GeminiService();
  final BusRepository _busRepository = BusRepository();

  Future<String> sendQuery(String userMessage, String languageCode) async {
    final busData = await _buildSystemPrompt(languageCode);
    return _service.sendMessage(
      userMessage: userMessage,
      systemPrompt: busData,
    );
  }

  Future<String> _buildSystemPrompt(String lang) async {
    final langNames = {'ar': 'Arabic', 'fr': 'French', 'tun': 'Tunisian Arabic', 'en': 'English'};
    final langName = langNames[lang] ?? 'French';

    final buses = await _busRepository.getBuses();
    final busJson = buses.map((b) => {
      'id': b.id,
      'line': b.lineNumber,
      'direction': b.direction,
      'occupancy': '${b.currentOccupancy}/${b.capacity}',
      'status': b.occupancyLabel,
      'nextDeparture': b.nextDeparture.toIso8601String(),
      'ramp': b.rampAvailable,
      'lowFloor': b.isLowFloor,
    }).toList();

    return '''
You are Basira, an AI assistant for the SORETRAS bus network in Sfax, Tunisia.
You help users with bus schedules, routes, accessibility info, and travel planning.
Always respond in $langName.
Answer ONLY transit-related questions about SORETRAS Sfax bus network.

Here is the current bus data:
$busJson

Key bus lines:
- Line 1: Nassria ↔ Bab Bhar (every 20 min, 05:30-22:00)
- Line 2: Sfax Sud ↔ Université (every 25 min, 05:45-21:30)
- Line 4: Aéroport ↔ Médina (every 30 min, 06:00-21:00)
- Line 6: Sakiet Ezzit ↔ Gare Routière (every 20 min, 05:30-22:00)
- Line 10: Chihia ↔ Nassria (every 25 min, 05:40-21:40)
- Line 15: Hay Ennour ↔ Centre Ville (every 30 min, 06:00-21:30)

All buses have a capacity of 80 passengers.
Some buses have ramps and/or low floors for accessibility.
If a user asks about something not related to Sfax bus transit, politely redirect them.
Keep responses concise and helpful.
''';
  }

  void clearHistory() => _service.clearHistory();
}
