import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/services/travel_time_service.dart';

enum _MapMode { normal, selectingOrigin, selectingDestination }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _updateTimer;
  final MapController _mapController = MapController();

  // Route planning state
  _MapMode _mode = _MapMode.normal;
  String? _originId;
  String? _destId;
  LatLng? _userLocation;
  bool _locationEnabled = false;

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

  // ─────── Geolocation ───────
  Future<void> _showMyLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context).error),
            content: Text('Please enable location services in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).ok),
              ),
            ],
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
      });

      _mapController.move(_userLocation!, 16);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error)),
      );
    }
  }

  // ─────── Map tap ───────
  Future<void> _onMapTap(String stationId) async {
    if (_mode == _MapMode.normal) return;

    setState(() {
      if (_mode == _MapMode.selectingOrigin) {
        _originId = stationId;
        _mode = _MapMode.selectingDestination;
      } else if (_mode == _MapMode.selectingDestination) {
        // Don't allow same station for both
        if (stationId != _originId) {
          _destId = stationId;
          _mode = _MapMode.normal;
        }
      }
    });
  }

  // ─────── Route planner helpers ───────
  void _startRoutePlanning() {
    setState(() {
      _mode = _MapMode.selectingOrigin;
      _originId = null;
      _destId = null;
    });
  }

  void _cancelRoutePlanning() {
    setState(() {
      _mode = _MapMode.normal;
      _originId = null;
      _destId = null;
    });
  }

  void _resetRoute() {
    _cancelRoutePlanning();
  }

  // ─────── Haversine distance ───────
  double _distanceKm(LatLng a, LatLng b) {
    const double R = 6371;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLng = _deg2rad(b.longitude - a.longitude);
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) * cos(_deg2rad(b.latitude)) *
        sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  // ─────── Build ───────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busesAsync = ref.watch(busesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build markers
    final markers = <Marker>[
      // Station markers
      ...allStations.values.map((station) {
        final isOrigin = station.id == _originId;
        final isDest = station.id == _destId;
        final isOnRoute = _originId != null && _destId != null && _isStationOnRoute(station.id);

        final color = isOrigin ? AppColors.primary :
                      isDest ? Colors.red :
                      isOnRoute ? Colors.orange :
                      null;

        return Marker(
          point: station.coordinates,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () async {
              if (_mode != _MapMode.normal) {
                await _onMapTap(station.id);
                // Center map on the picked station
                _mapController.move(station.coordinates, 15);
                HapticFeedback.lightImpact();
              } else {
                _showStationDialog(context, station);
              }
            },
            child: Icon(
              Icons.location_on,
              color: color ?? (isDark ? const Color(0xFF7CA971) : AppColors.primaryLight),
              size: isOrigin || isDest ? 44 : 36,
            ),
          ),
        );
      }),
      // User location marker
      if (_userLocation != null && _locationEnabled)
        Marker(
          point: _userLocation!,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
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
                  border: Border.all(color: isDark ? const Color(0xFF121A14) : Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    bus.lineNumber,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF121A14) : Colors.black,
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

    // Build route polylines
    final polylines = <Polyline>[];

    // Route line between origin and destination
    if (_originId != null && _destId != null) {
      final estimates = TravelTimeService().estimate(_originId!, _destId!);
      if (estimates.isNotEmpty) {
        final best = estimates.first;
        final line = allBusLines.firstWhere(
          (l) => l.lineNumber == best.busLine,
          orElse: () => allBusLines.first,
        );

        // Get stations between origin and destination along the line
        final oi = line.stationIds.indexOf(_originId!);
        final di = line.stationIds.indexOf(_destId!);
        final start = min(oi, di);
        final end = max(oi, di);

        // Reverse if destination comes before origin
        final ids = oi < di ? line.stationIds.sublist(start, end + 1) : line.stationIds.sublist(start, end + 1).reversed.toList();
        final points = ids.map((id) => allStations[id]!.coordinates).toList();

        if (points.length > 1) {
          polylines.add(Polyline(
            points: points,
            strokeWidth: 5,
            color: AppColors.primary,
          ));

          // Highlight the origin station area
          polylines.add(Polyline(
            points: [points.first, points.first],
            strokeWidth: 1,
            color: AppColors.primary,
          ));
        }
      }
    }

    // Determine what's shown in the instruction bar
    String? instruction;
    if (_mode == _MapMode.selectingOrigin) {
      instruction = '\u{1F4CD} Tap the map to select your origin station';
    } else if (_mode == _MapMode.selectingDestination) {
      instruction = '\u{1F4CD} Tap the map to select your destination station';
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(34.7406, 10.7590),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.basira.basira',
              ),
              MarkerLayer(markers: markers),
              if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            ],
          ),

          // Top instruction bar (when in route planning mode)
          if (instruction != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isDark ? const Color(0xFF1C2A1F) : Colors.white,
                  child: Row(
                    children: [
                      Icon(
                        _mode == _MapMode.selectingOrigin ? Icons.my_location : Icons.pin_drop,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          instruction,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelRoutePlanning,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Selected stations info bar (when both picked)
          if (_originId != null && _destId != null)
            _buildEstimationBar(isDark),

          // FABs
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location button
                FloatingActionButton(
                  heroTag: 'myLocation',
                  onPressed: _showMyLocation,
                  backgroundColor: isDark ? const Color(0xFF253528) : Colors.white,
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                // Plan trip / cancel button
                if (_mode != _MapMode.normal)
                  FloatingActionButton(
                    heroTag: 'cancelRoute',
                    onPressed: _cancelRoutePlanning,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.close, color: Colors.white),
                  )
                else
                  FloatingActionButton.extended(
                    heroTag: 'planTrip',
                    onPressed: _startRoutePlanning,
                    label: Text(l10n.planTrip),
                    icon: const Icon(Icons.route),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────── Estimation bar ───────
  Widget _buildEstimationBar(bool isDark) {
    final estimates = TravelTimeService().estimate(_originId!, _destId!);
    final origin = allStations[_originId]!;
    final dest = allStations[_destId]!;
    final localeCode = ref.watch(localeStringProvider);
    final originName = origin.nameForLocale(localeCode);
    final destName = dest.nameForLocale(localeCode);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2A1F) : Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station names
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      originName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pin_drop, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      destName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Estimates
              if (estimates.isEmpty)
                const Text('No direct bus route found.', style: TextStyle(color: Colors.redAccent))
              else
                ...estimates.take(3).map((est) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF253528) : const Color(0xFFE8F3E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Line ${est.busLine}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${est.stops} stops',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB0C4AE) : const Color(0xFF5A665D),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '~${est.estimatedDuration.inMinutes} min',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              const SizedBox(height: 4),
              // Reset button
              Center(
                child: TextButton.icon(
                  onPressed: _resetRoute,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Choose a different route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if a station is on the selected route
  bool _isStationOnRoute(String stationId) {
    if (_originId == null || _destId == null) return false;
    final estimates = TravelTimeService().estimate(_originId!, _destId!);
    if (estimates.isEmpty) return false;

    final best = estimates.first;
    final line = allBusLines.firstWhere(
      (l) => l.lineNumber == best.busLine,
      orElse: () => allBusLines.first,
    );

    final oi = line.stationIds.indexOf(_originId!);
    final di = line.stationIds.indexOf(_destId!);
    final start = min(oi, di);
    final end = max(oi, di);

    return line.stationIds.sublist(start, end + 1).contains(stationId);
  }

  // ─────── Station dialog ───────
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
