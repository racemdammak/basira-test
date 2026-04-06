import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/stations_mock.dart';
import '../trip/station_picker_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _updateTimer;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.invalidate(busesProvider);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busesAsync = ref.watch(busesProvider);

    final markers = <Marker>[
      // Station markers
      ...allStations.values.map((station) {
        return Marker(
          point: station.coordinates,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showStationDialog(context, station),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryLight,
              size: 36,
            ),
          ),
        );
      }),
    ];

    // Add bus markers
    if (busesAsync case AsyncData(:final value)) {
      for (final bus in value) {
        markers.add(
          Marker(
            point: bus.currentPosition,
            width: 30,
            height: 30,
            child: Tooltip(
              message: '${l10n.nextBus} ${bus.lineNumber} - ${bus.direction}',
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    bus.lineNumber,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(34.7406, 10.7590),
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.basira.basira',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'backToMenu',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'planTrip',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StationPickerScreen(),
                ),
              );
            },
            label: Text(l10n.planTrip),
            icon: const Icon(Icons.directions_bus),
            backgroundColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  void _showStationDialog(BuildContext context, dynamic station) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);
    final name = station.nameForLocale(code);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(name),
        content: Text(
          '${l10n.busLines}: ${station.lineNumbers.join(", ")}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
