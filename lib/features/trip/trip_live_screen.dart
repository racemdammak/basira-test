import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/services/travel_time_service.dart';
import '../../l10n/app_localizations.dart';

/// Shows the live position of a bus during an active trip.
class TripLiveScreen extends ConsumerStatefulWidget {
  final String originId;
  final String destinationId;
  final String? busLine;

  const TripLiveScreen({
    super.key,
    required this.originId,
    required this.destinationId,
    this.busLine,
  });

  @override
  ConsumerState<TripLiveScreen> createState() => _TripLiveScreenState();
}

class _TripLiveScreenState extends ConsumerState<TripLiveScreen> {
  Timer? _timer;
  String? _busId;
  int _stopsRemaining = 0;
  double _progress = 0; // 0-1

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (_busId == null) return;

    // Simulate progress for demo
    setState(() {
      _stopsRemaining = ((_stopsRemaining - 1)).clamp(0, _stopsRemaining);
      _progress = (_progress + 0.02).clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);
    final origin = allStations[widget.originId];
    final destination = allStations[widget.destinationId];

    if (origin == null || destination == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: Text(l10n.invalidTripData)),
      );
    }

    final estimate = ref.watch(
      travelEstimateProvider((
        originId: widget.originId,
        destinationId: widget.destinationId,
      )),
    );

    final firstLine = estimate.isNotEmpty ? estimate.first.busLine : widget.busLine;
    final servingStationIds = allBusLines
        .firstWhere(
          (l) => l.lineNumber == firstLine,
          orElse: () => allBusLines.first,
        )
        .stationIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(code == 'ar' ? '\u0627\u0644\u0631\u062D\u0644\u0629 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629' : 'Live Trip'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.accent.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),

          // Route info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _StationRow(
                  name: origin.nameForLocale(code),
                  isStart: true,
                  isPassed: _progress > 0.5,
                ),
                ..._buildIntermediateStations(servingStationIds, widget.originId, widget.destinationId, code),
                _StationRow(
                  name: destination.nameForLocale(code),
                  isStart: false,
                  isPassed: false,
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // ETA display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _progress > 0.9 ? Icons.flag : Icons.directions_bus,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progress > 0.9
                        ? '${l10n.arrivingAt} ${destination.nameForLocale(code)}'
                        : '${estimate.isEmpty ? '' : '~'}${estimate.isNotEmpty ? '${estimate.first.estimatedDuration.inMinutes - (_progress * 5).round()} ${l10n.minToDestination}' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIntermediateStations(
    List<String> allStationIds,
    String originId,
    String destinationId,
    String code,
  ) {
    final originIdx = allStationIds.indexOf(originId);
    final destIdx = allStationIds.indexOf(destinationId);
    if (originIdx == -1 || destIdx == -1) return [];

    // Use min/max for bidirectional
    final start = originIdx < destIdx ? originIdx + 1 : destIdx + 1;
    final end = originIdx < destIdx ? destIdx : originIdx;

    return List.generate(end - start, (i) {
      final station = allStations[allStationIds[start + i]];
      if (station == null) return const SizedBox.shrink();
      return _StationRow(
        name: station.nameForLocale(code),
        isStart: false,
        isPassed: _progress > (i / (end - start)) * 0.5,
      );
    });
  }
}

class _StationRow extends StatelessWidget {
  final String name;
  final bool isStart;
  final bool isPassed;

  const _StationRow({
    required this.name,
    required this.isStart,
    required this.isPassed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isStart
                      ? Colors.green
                      : isPassed
                          ? AppColors.primary
                          : AppColors.accent,
                ),
              ),
              if (!isStart)
                Container(
                  width: 2,
                  height: 24,
                  color: AppColors.primary.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              decoration: isPassed ? TextDecoration.lineThrough : null,
              color: isPassed ? Colors.grey : null,
            ),
          ),
        ],
      ),
    );
  }
}
