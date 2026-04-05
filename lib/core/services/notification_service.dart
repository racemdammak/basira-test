import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'tts_service.dart';
import 'haptic_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final TtsService _tts = TtsService();
  final HapticService _haptic = HapticService();
  int _notificationId = 0;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    _tts.init();
    _initialized = true;
  }

  Future<void> notify({
    required String title,
    required String body,
    String locale = 'fr',
    HapticPattern haptic = HapticPattern.confirmation,
  }) async {
    if (!_initialized) await init();

    final id = _notificationId++;

    const androidDetails = AndroidNotificationDetails(
      'basira_channel',
      'Basira Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);

    // Voice alert + haptic
    await _tts.speak('$title. $body', locale: locale);
    await _haptic.play(haptic);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
