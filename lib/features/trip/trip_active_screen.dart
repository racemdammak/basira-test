import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../core/services/haptic_service.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/favorite_route.dart';
import 'trip_live_screen.dart';

class TripActiveScreen extends ConsumerStatefulWidget {
  const TripActiveScreen({super.key});

  @override
  ConsumerState<TripActiveScreen> createState() => _TripActiveScreenState();
}

class _TripActiveScreenState extends ConsumerState<TripActiveScreen> {
  Timer? _tripTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tripTimer = Timer.periodic(const Duration(seconds: 3), _checkTripEvents);
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    super.dispose();
  }

  void _checkTripEvents(Timer timer) {
    if (!mounted) return;
    _elapsedSeconds += 3;
    final trip = ref.read(activeTripProvider);
    if (!trip.isActive) return;

    if (_elapsedSeconds == 60 && !trip.isBoarded) {
      _triggerNotification(HapticPattern.busApproaching, localeKey: 'busApproaching');
    } else if (_elapsedSeconds == 120 && !trip.isBoarded) {
      _triggerNotification(HapticPattern.busArrived, localeKey: 'busArrived');
    }
  }

  void _triggerNotification(HapticPattern pattern, {required String localeKey}) {
    final notifications = ref.read(notificationServiceProvider);
    final l10n = AppLocalizations.of(context);

    String title = '';
    switch (localeKey) {
      case 'busApproaching': title = l10n.busApproaching; break;
      case 'busArrived': title = l10n.busArrived; break;
      case 'destinationSoon': title = l10n.destinationSoon; break;
      case 'destinationArrived': title = l10n.youHaveArrived; break;
    }

    if (ref.read(voiceAlertsEnabledProvider)) {
      notifications.notify(title: title, body: '', haptic: pattern);
    } else {
      notifications.notify(title: title, body: '', haptic: HapticPattern.confirmation);
    }
  }

  Future<void> _startTrip() async {
    ref.read(activeTripProvider.notifier).state = ref.read(activeTripProvider).copyWith(
      isBoarded: true,
      startTime: DateTime.now(),
    );
    _triggerNotification(HapticPattern.confirmation, localeKey: 'busApproaching');
  }

  Future<void> _reportCrowd() async {
    final trip = ref.read(activeTripProvider);
    // FIXED: Uses trip.busLine instead of the old trip.busId
    await ref.read(busRepositoryProvider).reportCrowd(trip.busLine ?? 'unknown', 76);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).crowdReportSent)),
      );
    }
  }

  Future<void> _reportDelay() async {
    final minute = await _showDelayDialog(context);
    if (minute != null && mounted) {
      final trip = ref.read(activeTripProvider);
      ref.read(storageServiceProvider).addDelayReport(DelayReport(
        // FIXED: Uses trip.busLine
        busLine: trip.busLine ?? 'unknown',
        stationId: trip.originId ?? '',
        delayMinutes: minute,
        timestamp: DateTime.now(),
      ));
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.delayReported)),
      );
    }
  }

  Future<int?> _showDelayDialog(BuildContext context) {
    return showDialog<int>(context: context, builder: (_) => _DelayDialog());
  }

  Future<void> _shareTrip() async {
    final trip = ref.read(activeTripProvider);
    final code = ref.read(localeStringProvider);
    final origin = allStations[trip.originId];
    final destination = allStations[trip.destinationId];
    if (origin == null || destination == null) return;

    final l10n = AppLocalizations.of(context);
    final message = l10n.shareMessage(
      origin.nameForLocale(code),
      destination.nameForLocale(code),
      trip.busLine ?? 'N/A', // FIXED
    );

    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routeCopied)),
      );
    }
  }

  Future<void> _endTrip() async {
    final l10n = AppLocalizations.of(context);
    final tripState = ref.read(activeTripProvider);
    
    if (!tripState.isLastLeg) {
      // Advance to the next transfer leg!
      ref.read(activeTripProvider.notifier).state = tripState.copyWith(
        currentLegIndex: tripState.currentLegIndex + 1,
        isBoarded: false, 
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.legComplete(ref.read(activeTripProvider).busLine ?? '?'))),
      );
    } else {
      // Fully arrived at final destination
      ref.read(activeTripProvider.notifier).state = const ActiveTripState();
      ref.read(notificationServiceProvider).cancelAll();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = ref.watch(activeTripProvider);
    final origin = allStations[trip.originId];
    final destination = allStations[trip.destinationId];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.routePlanned),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareTrip,
            tooltip: l10n.shareRoute,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (origin != null && destination != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle, size: 12, color: Colors.green),
                            Container(width: 2, height: 20, color: Colors.grey),
                            const Icon(Icons.flag, size: 12, color: Colors.red),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                origin.nameForLocale(ref.read(localeStringProvider)),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destination.nameForLocale(ref.read(localeStringProvider)),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripLiveScreen(
                          originId: trip.originId!,
                          destinationId: trip.destinationId!,
                          busLine: trip.busLine, // FIXED
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: Text(l10n.liveTracking),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        trip.isBoarded ? Icons.directions_bus : Icons.hourglass_empty,
                        size: 48,
                        color: trip.isBoarded ? AppColors.available : AppColors.crowded,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trip.isBoarded ? l10n.onBus : l10n.waitingForBus,
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!trip.isBoarded) ...[
                        ElevatedButton(
                          onPressed: _startTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.available,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_bus, size: 28),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  l10n.onTheBus,
                                  style: const TextStyle(fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: _reportCrowd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.full,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.report, size: 28),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.busFull,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reportDelay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, size: 28),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.reportDelay,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _endTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: trip.isLastLeg ? AppColors.primaryLight : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(trip.isLastLeg ? Icons.close : Icons.transfer_within_a_station, size: 28),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                trip.isLastLeg ? l10n.endTrip : l10n.completeLegAndTransfer,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DelayDialog extends StatefulWidget {
  @override
  State<_DelayDialog> createState() => _DelayDialogState();
}

class _DelayDialogState extends State<_DelayDialog> {
  int _selected = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reportDelay),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.howLateIsBus),
          const SizedBox(height: 12),
          DropdownButton<int>(
            value: _selected,
            items: [5, 10, 15, 20, 30].map((m) {
              return DropdownMenuItem(value: m, child: Text('$m ${l10n.minutes}'));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selected = v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}