import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../core/services/haptic_service.dart';

class TripActiveScreen extends ConsumerStatefulWidget {
  const TripActiveScreen({super.key});

  @override
  ConsumerState<TripActiveScreen> createState() => _TripActiveScreenState();
}

class _TripActiveScreenState extends ConsumerState<TripActiveScreen> {
  bool _isBoarded = false;
  Timer? _tripTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tripTimer = Timer.periodic(const Duration(seconds: 5), _checkTripEvents);
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    // Clear active trip
    ref.read(activeTripProvider.notifier).state = const ActiveTripState();
    ref.read(notificationServiceProvider).cancelAll();
    super.dispose();
  }

  void _checkTripEvents(Timer timer) {
    if (!mounted) return;

    _elapsedSeconds += 5;
    final trip = ref.read(activeTripProvider);
    if (!trip.isActive) return;

    // Simulate trip progression
    // At ~60s: approaching
    // At ~120s: arrived
    // At ~180s: destination soon
    // At ~240s: destination arrived
    if (_elapsedSeconds == 60 && !_isBoarded) {
      _triggerNotification(HapticPattern.busApproaching,
          titleKey: 'busApproaching', localeKey: 'busApproaching');
    } else if (_elapsedSeconds == 120 && !_isBoarded) {
      _triggerNotification(HapticPattern.busArrived,
          titleKey: 'busArrived', localeKey: 'busArrived');
    }
  }

  void _triggerNotification(HapticPattern pattern,
      {required String titleKey, required String localeKey}) {
    final notifications = ref.read(notificationServiceProvider);
    final l10n = AppLocalizations.of(context);

    String title = '';
    String body = '';
    switch (localeKey) {
      case 'busApproaching':
        title = l10n.busApproaching;
        body = '';
        break;
      case 'busArrived':
        title = l10n.busArrived;
        body = '';
        break;
      case 'destinationSoon':
        title = l10n.destinationSoon;
        body = '';
        break;
      case 'destinationArrived':
        title = l10n.youHaveArrived;
        body = '';
        break;
    }

    if (ref.read(voiceAlertsEnabledProvider)) {
      notifications.notify(
          title: title, body: body, haptic: pattern);
    } else {
      // Just show notification without voice/haptic
      notifications.notify(
          title: title, body: body, haptic: HapticPattern.confirmation);
    }
  }

  Future<void> _startTrip() async {
    setState(() {
      _isBoarded = true;
    });
    ref.read(activeTripProvider.notifier).state =
        ref.read(activeTripProvider).copyWith(
              isBoarded: true,
              startTime: DateTime.now(),
            );

    _triggerNotification(HapticPattern.confirmation,
        titleKey: 'startTrip', localeKey: 'busApproaching');

    // Update ref
    ref.read(activeTripProvider.notifier).state =
        ref.read(activeTripProvider).copyWith(isBoarded: true);
  }

  Future<void> _reportCrowd() async {
    final repo = ref.read(busRepositoryProvider);
    final trip = ref.read(activeTripProvider);

    // Simulate: current bus is 95% full
    await repo.reportCrowd(trip.busId ?? 'unknown', 76);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.crowdReportSent)),
      );
    }
  }

  Future<void> _endTrip() async {
    ref.read(activeTripProvider.notifier).state = const ActiveTripState();
    ref.read(notificationServiceProvider).cancelAll();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(activeTripProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.routePlanned),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Trip status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _isBoarded ? Icons.directions_bus : Icons.hourglass_empty,
                        size: 48,
                        color: _isBoarded ? AppColors.available : AppColors.crowded,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isBoarded
                            ? '🟢 On bus'
                            : 'Waiting for bus...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_isBoarded) ...[
                // Large "I'm on the bus" button
            ],

            // Big action buttons
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_isBoarded)
                        ElevatedButton.icon(
                          onPressed: _startTrip,
                          icon: const Icon(Icons.directions_bus, size: 28),
                          label: Text(l10n.onTheBus, style: const TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.available,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 18),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _reportCrowd,
                        icon: const Icon(Icons.report, size: 28),
                        label: Text(l10n.busFull,
                            style: const TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.full,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _endTrip,
                        icon: const Icon(Icons.close, size: 28),
                        label:
                            Text(l10n.endTrip, style: const TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
