import 'dart:convert';
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

  // --- NEW: AI INTENT EXTRACTOR FOR BLIND MODE ---
  Future<Map<String, String>?> extractRouteIntent(String userMessage) async {
    final prompt = '''
You are an intent extractor for the Basira Sfax transit app.
Extract the origin and destination station IDs from the user's message.
Available station IDs: bab_bhar, centre_ville, nassria, gare_sncft, port_sfax, hopital_hb, route_tunis_km2, route_tunis_km4, sakiet_ezzit, route_mahdia_km3, route_mahdia_km5, sakiet_eddaier, sidi_mansour, route_teniour_km3, chihia, route_gremda_km3, gremda, route_el_ain_km3, el_ain, m_chaker_km3, m_chaker_km6, route_soukra_km3, aeroport, cite_el_habib, route_gabes_km3, sfax_sud, thyna.

Map common Arabic, French, and English words to their IDs:
"مطار" , "matar" , "airport" -> aeroport
"سبيطار" , "مستشفى" , "hopital" , "hospital" -> hopital_hb
"محطة" , "ترينو" , "train" -> gare_sncft
"ساقية" , "sakiet" -> sakiet_ezzit
"شيحية" , "shia" , "chihia" -> chihia
"باب بحر" , "beb bhar" , "bab bhar" -> bab_bhar
"نصرية" , "nasria" , "nassria" -> nassria

If the user's origin is not explicitly mentioned, ALWAYS default to "bab_bhar".
Return ONLY a valid JSON object with "origin" and "destination" keys. Do not include markdown blocks, greetings, or any other text.
Example: {"origin": "bab_bhar", "destination": "aeroport"}
''';
    final response = await _service.sendMessage(userMessage: userMessage, systemPrompt: prompt);
    try {
      // Clean the response just in case Gemini wraps it in markdown (```json ... ```)
      final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleaned);
      return {
         'origin': data['origin'].toString(),
         'destination': data['destination'].toString(),
      };
    } catch (e) {
      print('Intent Extraction Error: $e');
      return null;
    }
  }

  Future<String> _buildSystemPrompt(String lang) async {
    final langNames = {'ar': 'Arabic', 'fr': 'French', 'en': 'English'};
    final langName = langNames[lang] ?? 'Arabic';

    final buses = await _busRepository.getBuses();
    final busJson = buses.map((b) => {
      'id': b.id,
      'line': b.lineNumber,
      'direction': b.direction,
      'occupancy': '${b.currentOccupancy}/${b.capacity}',
      'status': b.occupancyLabel,
      'nextDeparture': b.nextDeparture.toIso8601String(),
    }).toList();

    return '''
You are Basira, a smart AI assistant for the SORETRAS bus network in Sfax, Tunisia.
You help people find buses, schedules, and navigate the city.
Always respond ONLY in $langName. 

PHONETIC CORRECTIONS FOR VOICE:
The speech engine often mishears these Sfaxian stations:
- "North Korea", "Nasria" -> Nassria
- "Bendford", "Pepper", "Bab bar" -> Bab Bhar
- "Shake it", "Sakiet" -> Sakiet Ezzit
- "Chia", "Shia" -> Chihia
- "Airport", "Matar" -> Aéroport

INSTRUCTIONS:
1. User current data: $busJson
2. Be concise but precise about times.
3. If they ask when a bus comes, look at 'nextDeparture'.
4. If they want to go somewhere, suggest the best line.
5. If they ask in another language, respond ONLY in $langName.
''';
  }


  void clearHistory() => _service.clearHistory();
}