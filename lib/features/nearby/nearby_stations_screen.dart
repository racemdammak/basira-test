import 'dart:math' show sin, cos, sqrt;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/stations_mock.dart';
import '../../l10n/app_localizations.dart';
import '../trip/station_picker_screen.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                isClosest ? Icons.location_on : Icons.location_on_outlined,
                color: isClosest ? Colors.red : AppColors.primary,
              ),
              title: Text(station.nameForLocale(code)),
              subtitle: Text(
                'Lines: ${station.lineNumbers.join(", ")}  \u00B7  ${(dist / 1000).toStringAsFixed(1)} km away',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StationPickerScreen(
                        preselectedDestination: station,
                      ),
                    ),
                  );
                },
                child: Text(l10n.go),
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
