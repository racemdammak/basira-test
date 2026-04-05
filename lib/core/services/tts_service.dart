import 'package:flutter_tts/flutter_tts.dart';

// ignore_for_file: unnecessary_getters_setters

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;

  set enabled(bool v) => _enabled = v;
  bool get enabled => _enabled;

  Future<void> init() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  String _localeCode(String locale) {
    switch (locale) {
      case 'ar':
        return 'ar-SA';
      case 'tun':
        return 'ar-TN';
      case 'fr':
        return 'fr-FR';
      case 'en':
        return 'en-US';
      default:
        return 'fr-FR';
    }
  }

  Future<void> speak(String text, {String locale = 'fr'}) async {
    if (!_enabled) return;
    try {
      await _tts.setLanguage(_localeCode(locale));
      await _tts.speak(text);
    } catch (_) {
      // TTS may fail on missing voice — silently skip
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
