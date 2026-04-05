import 'package:vibration/vibration.dart';

// ignore_for_file: unnecessary_getters_setters

enum HapticPattern { busApproaching, busArrived, destinationSoon, destinationArrived, confirmation }

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _enabled = true;
  set enabled(bool v) => _enabled = v;
  bool get enabled => _enabled;

  Future<void> play(HapticPattern pattern) async {
    if (!_enabled) return;
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    switch (pattern) {
      case HapticPattern.busApproaching:
        // 3 short pulses
        for (int i = 0; i < 3; i++) {
          await Vibration.vibrate(duration: 200);
          await Future.delayed(const Duration(milliseconds: 300));
        }
        break;
      case HapticPattern.busArrived:
        // 1 long pulse
        await Vibration.vibrate(duration: 800);
        break;
      case HapticPattern.destinationSoon:
        // increasing intensity ramp
        for (int i = 1; i <= 4; i++) {
          await Vibration.vibrate(duration: i * 150);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        break;
      case HapticPattern.destinationArrived:
        // 2 long pulses
        await Vibration.vibrate(duration: 600);
        await Future.delayed(const Duration(milliseconds: 200));
        await Vibration.vibrate(duration: 600);
        break;
      case HapticPattern.confirmation:
        // 1 subtle short tap
        await Vibration.vibrate(duration: 50);
        break;
    }
  }
}
