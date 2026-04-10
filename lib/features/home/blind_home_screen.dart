import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/services/stt_service.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';
import '../trip/trip_active_screen.dart';

class BlindHomeScreen extends ConsumerStatefulWidget {
  const BlindHomeScreen({super.key});

  @override
  ConsumerState<BlindHomeScreen> createState() => _BlindHomeScreenState();
}

class _BlindHomeScreenState extends ConsumerState<BlindHomeScreen> {
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final locale = ref.read(localeStringProvider);
      ref.read(ttsServiceProvider).speak(l10n.blindModeActivated, locale: locale);
    });
  }

  void _toggleListening() async {
    final l10n = AppLocalizations.of(context);
    final stt = ref.read(sttServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final locale = ref.read(localeStringProvider);

    if (_isListening) {
      setState(() => _isListening = false);
      stt.stop();
      haptic.play(HapticPattern.confirmation);
    } else {
      setState(() => _isListening = true);
      haptic.play(HapticPattern.busArrived); 
      await tts.speak(l10n.listening, locale: locale);
      
      final text = await stt.startListening(locale);
      if (mounted) {
        setState(() => _isListening = false);
        _handleCommand(text ?? '');
      }
    }
  }

  void _handleCommand(String text) async {
    final l10n = AppLocalizations.of(context);
    final tts = ref.read(ttsServiceProvider);
    final locale = ref.read(localeStringProvider);
    final chatRepo = ref.read(chatRepositoryProvider);

    if (text.isEmpty) {
       tts.speak(l10n.didNotCatch, locale: locale);
       return;
    }
    
    // 1. Get a smart response from the main AI agent
    try {
      final aiResponse = await chatRepo.sendQuery(text, locale);
      await tts.speak(aiResponse, locale: locale);

      // 2. Background: Extract intent to see if we should start tracking/trip planning
      final intent = await chatRepo.extractRouteIntent(text);
      if (intent != null && intent['destination'] != null && intent['destination'] != 'null') {
        final originId = intent['origin'] ?? 'bab_bhar';
        final destId = intent['destination']!;
        final trips = await ref.read(busRepositoryProvider).findTripOptions(originId, destId);

        if (trips.isNotEmpty) {
          final trip = trips.first;
          ref.read(activeTripProvider.notifier).state = ActiveTripState(
            trip: trip,
            currentLegIndex: 0,
            isBoarded: false,
          );
          // No need to speak anything extra here, the AI response usually covers it
        }
      }
    } catch (e) {
      await tts.speak(l10n.blindError, locale: locale);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleListening,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _isListening ? Colors.red.shade900 : Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 120,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isListening ? l10n.loading : l10n.voiceInput,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Semantics(
                  label: l10n.settings,
                  child: IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: l10n.settings,
                    onPressed: () {
                      final locale = ref.read(localeStringProvider);
                      ref.read(hapticServiceProvider).play(HapticPattern.confirmation);
                      ref.read(ttsServiceProvider).speak(l10n.settingsOpened, locale: locale);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const SettingsScreen())
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}