import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/bus_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/station.dart';
import '../core/services/tts_service.dart';
import '../core/services/haptic_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/stt_service.dart';
import '../data/models/trip.dart';

const _keyDarkMode = 'dark_mode';

// Locale provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('ar');
});

// Language code helper
final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(localeProvider).languageCode;
});

final localeStringProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.toLanguageTag().split('-')[0]; // 'en', 'ar', 'fr', etc.
});

final ttsLocaleProvider = Provider<String>((ref) {
  final code = ref.watch(languageCodeProvider);
  switch (code) {
    case 'fr': return 'fr-FR';
    case 'ar': return 'ar-SA';
    case 'tun': return 'ar-TN';
    default: return 'en-US';
  }
});

// Repositories
final busRepositoryProvider = Provider<BusRepository>((ref) => BusRepository());
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

// Services
final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final sttServiceProvider = Provider<SttService>((ref) => SttService());

// Buses list
final busesProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getBuses();
});

// Bus lines
final busLinesProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getBusLines();
});

// All stations
final allStationsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getAllStations();
});

// Trip options
class TripSearch {
  final String originId;
  final String destId;
  const TripSearch({required this.originId, required this.destId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripSearch && originId == other.originId && destId == other.destId;

  @override
  int get hashCode => originId.hashCode ^ destId.hashCode;
}

final tripOptionsProvider = FutureProvider.family.autoDispose((
  ref, TripSearch search,
) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.findTripOptions(search.originId, search.destId);
});

// Buses for route
final busesForRouteProvider = FutureProvider.family.autoDispose((
  ref, TripSearch search,
) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getBusesForRoute(search.originId, search.destId);
});

// Station search
final stationSearchProvider = FutureProvider.family.autoDispose<List<Station>, String>((
  ref, String query,
) async {
  final repo = ref.watch(busRepositoryProvider);
  return repo.searchStations(query);
});

// Chat history
final chatMessagesProvider = StateProvider<List<Map<String, String>>>((ref) => []);
final chatIsLoadingProvider = StateProvider<bool>((ref) => false);

// Active trip state for Multi-leg journeys
class ActiveTripState {
  final Trip? trip;
  final int currentLegIndex;
  final bool isBoarded;
  final DateTime? startTime;

  const ActiveTripState({
    this.trip,
    this.currentLegIndex = 0,
    this.isBoarded = false,
    this.startTime,
  });

  ActiveTripState copyWith({
    Trip? trip,
    int? currentLegIndex,
    bool? isBoarded,
    DateTime? startTime,
  }) {
    return ActiveTripState(
      trip: trip ?? this.trip,
      currentLegIndex: currentLegIndex ?? this.currentLegIndex,
      isBoarded: isBoarded ?? this.isBoarded,
      startTime: startTime ?? this.startTime,
    );
  }

  bool get isActive => trip != null;
  
  // Helpers to get the current active leg of the journey
  Section? get currentSection => trip != null && currentLegIndex < trip!.sections.length ? trip!.sections[currentLegIndex] : null;
  bool get isLastLeg => trip != null && currentLegIndex == trip!.sections.length - 1;
  
  String? get originId => currentSection?.from.id;
  String? get destinationId => currentSection?.to.id;
  String? get busLine => currentSection?.busLineNumber;
  String? get finalDestinationId => trip?.destination.id;
}

final activeTripProvider = StateProvider<ActiveTripState>((ref) {
  return const ActiveTripState();
});

// Voice settings
final voiceAlertsEnabledProvider = StateProvider<bool>((ref) => true);
final hapticsEnabledProvider = StateProvider<bool>((ref) => true);
final fontSizeProvider = StateProvider<double>((ref) => 1.0); // textScaleFactor

// Dark mode with persistent storage
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, state);
  }

  Future<void> setDarkMode(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, state);
  }
}
