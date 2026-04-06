import 'package:flutter/services.dart';

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

    switch (pattern) {
      case HapticPattern.busApproaching:
        for (int i = 0; i < 3; i++) {
          HapticFeedback.vibrate();
          await Future.delayed(const Duration(milliseconds: 300));
        }
        break;
      case HapticPattern.busArrived:
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.destinationSoon:
        for (int i = 1; i <= 4; i++) {
          HapticFeedback.mediumImpact();
          await Future.delayed(Duration(milliseconds: 100 + (i * 50)));
        }
        break;
      case HapticPattern.destinationArrived:
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.confirmation:
        HapticFeedback.lightImpact();
        break;
    }
  }
}
