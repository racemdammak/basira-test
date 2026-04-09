import 'dart:math' show sin, cos, sqrt;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/stations_mock.dart';
import '../../l10n/app_localizations.dart';
import '../trip/station_picker_screen.dart';

/// Reusable station icon widget with rounded container background.
class _StationIcon extends StatelessWidget {
  final bool isClosest;

  const _StationIcon({required this.isClosest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isClosest ? Colors.red.withValues(alpha: 0.12) : AppColors.primaryLight.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isClosest ? Icons.location_on : Icons.location_on_outlined,
        color: isClosest ? Colors.red : AppColors.primary,
        size: 20,
      ),
    );
  }
}

class NearbyStationsScreen extends ConsumerWidget {
  const NearbyStationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);

    // Simulated user position (Sfax centre)
    final userPos = const LatLng(34.7406, 10.7590);

    final sorted = allStations.values.toList()
      ..sort((a, b) {
        final distA = _distance(userPos, a.coordinates);
        final distB = _distance(userPos, b.coordinates);
        return distA.compareTo(distB);
      });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.nearbyStations),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final station = sorted[index];
          final dist = _distance(userPos, station.coordinates);
          final isClosest = index < 3;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _StationIcon(isClosest: isClosest),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.nameForLocale(code),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.linesLabel(station.lineNumbers.join(", ")),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.kmAway((dist / 1000).toStringAsFixed(1)),
                          style: TextStyle(
                            fontSize: 12,
                            color: isClosest ? Colors.red.shade700 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StationPickerScreen(
                            preselectedDestination: station,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      l10n.go,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Haversine distance in metres
  double _distance(LatLng a, LatLng b) {
    const r = 6371000;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final result = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(a.latitude)) * cos(_rad(b.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * sqrt(result);
  }

  double _rad(double deg) => deg * 3.141592653589793 / 180;
}
