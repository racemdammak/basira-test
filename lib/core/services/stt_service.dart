import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  
  void stop() => _stt.stop();

  Future<bool> _init() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize();
    return _initialized;
  }

  Future<String?> startListening(String locale) async {
    final ready = await _init();
    if (!ready) return null;

    String result = '';
    final completer = Completer<String?>();

    _stt.listen(
      localeId: _localeCode(locale),
      onResult: (speechResult) {
        result = speechResult.recognizedWords;
        if (speechResult.finalResult) {
          completer.complete(result.isEmpty ? null : result);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );

    // Auto-complete after 30s if no final result
    Future.delayed(const Duration(seconds: 32), () {
      if (!completer.isCompleted) {
        _stt.stop();
        completer.complete(result.isEmpty ? null : result);
      }
    });

    return completer.future;
  }

  String _localeCode(String locale) {
    // Map locale to speech_to_text locale identifier
    switch (locale) {
      case 'ar':
        return 'ar_SA';
      case 'tun':
        return 'ar_TN';
      case 'fr':
        return 'fr_FR';
      case 'en':
        return 'en_US';
      default:
        return 'fr_FR';
    }
  }
}
