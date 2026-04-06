import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/bus_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/station.dart';
import '../core/services/tts_service.dart';
import '../core/services/haptic_service.dart';
import '../core/services/notification_service.dart';

// Locale provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
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

// Active trip state
class ActiveTripState {
  final String? busId;
  final String? originId;
  final String? destinationId;
  final bool isBoarded;
  final DateTime? startTime;

  const ActiveTripState({
    this.busId,
    this.originId,
    this.destinationId,
    this.isBoarded = false,
    this.startTime,
  });

  ActiveTripState copyWith({
    String? busId,
    String? originId,
    String? destinationId,
    bool? isBoarded,
    DateTime? startTime,
  }) {
    return ActiveTripState(
      busId: busId ?? this.busId,
      originId: originId ?? this.originId,
      destinationId: destinationId ?? this.destinationId,
      isBoarded: isBoarded ?? this.isBoarded,
      startTime: startTime ?? this.startTime,
    );
  }

  bool get isActive => busId != null && destinationId != null;
}

final activeTripProvider = StateProvider<ActiveTripState>((ref) {
  return const ActiveTripState();
});

// Voice settings
final voiceAlertsEnabledProvider = StateProvider<bool>((ref) => true);
final hapticsEnabledProvider = StateProvider<bool>((ref) => true);
final fontSizeProvider = StateProvider<double>((ref) => 1.0); // textScaleFactor
