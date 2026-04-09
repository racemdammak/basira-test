import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps; 
import 'package:latlong2/latlong.dart' as ll2; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/models/bus.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/services/travel_time_service.dart';

// --- ADD THESE 3 IMPORTS FOR THE GPS TRACKING FEATURE ---
import '../../data/services/storage_service.dart';
import '../../data/models/favorite_route.dart';
import '../trip/trip_active_screen.dart'; // This is the line fixing your error!


enum _MapMode { normal, selectingOrigin, selectingDestination }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _updateTimer;
  // Using Completer for Google Maps controller
  final Completer<gmaps.GoogleMapController> _mapController = Completer<gmaps.GoogleMapController>();

  // Route planning state
  _MapMode _mode = _MapMode.normal;
  String? _originId;
  String? _destId;
  gmaps.LatLng? _userLocation;
  bool _locationEnabled = false;

  // Helper to convert latlong2 to Google Maps LatLng
  gmaps.LatLng _convertLatLng(ll2.LatLng pos) => gmaps.LatLng(pos.latitude, pos.longitude);

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
            content: Text(AppLocalizations.of(context).enableLocationText),
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
        _userLocation = gmaps.LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
      });

      final controller = await _mapController.future;
      controller.animateCamera(gmaps.CameraUpdate.newLatLngZoom(_userLocation!, 16));
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

  void _resetRoute() => _cancelRoutePlanning();

  // ─────── Build ───────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busesAsync = ref.watch(busesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build markers
    final Set<gmaps.Marker> markers = {};

    // 1. Station markers
    for (final station in allStations.values) {
      final isOrigin = station.id == _originId;
      final isDest = station.id == _destId;
      final isOnRoute = _originId != null && _destId != null && _isStationOnRoute(station.id);

      final hue = isOrigin ? gmaps.BitmapDescriptor.hueGreen :
                  isDest ? gmaps.BitmapDescriptor.hueRed :
                  isOnRoute ? gmaps.BitmapDescriptor.hueOrange :
                  gmaps.BitmapDescriptor.hueAzure;

      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId(station.id),
          position: _convertLatLng(station.coordinates),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () async {
            if (_mode != _MapMode.normal) {
              await _onMapTap(station.id);
              final controller = await _mapController.future;
              controller.animateCamera(gmaps.CameraUpdate.newLatLngZoom(_convertLatLng(station.coordinates), 15));
              HapticFeedback.lightImpact();
            } else {
              // Linked the new Station Details Bottom Sheet here!
              _showStationDetails(station); 
            }
          },
        ),
      );
    }

    // 2. Add bus markers
    if (busesAsync case AsyncData(:final value)) {
      for (final bus in value) {
        markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(bus.id),
            position: _convertLatLng(bus.currentPosition),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow),
            rotation: bus.heading, // The icon will now rotate to face the road!
            onTap: () {
               // Linked the new Bus Details Bottom Sheet here!
               _showBusDetails(bus);
            },
          ),
        );
      }
    }

    // Build route polylines
    final Set<gmaps.Polyline> polylines = {};

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
        final points = ids.map((id) => _convertLatLng(allStations[id]!.coordinates)).toList();

        if (points.length > 1) {
          polylines.add(gmaps.Polyline(
            polylineId: const gmaps.PolylineId('route'),
            points: points,
            width: 5,
            color: AppColors.primary,
          ));
        }
      }
    }

    String? instruction;
    if (_mode == _MapMode.selectingOrigin) {
      instruction = l10n.tapToSelectOrigin;
    } else if (_mode == _MapMode.selectingDestination) {
      instruction = l10n.tapToSelectDest;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps Widget replacing FlutterMap
          gmaps.GoogleMap(
            initialCameraPosition: const gmaps.CameraPosition(
              target: gmaps.LatLng(34.7406, 10.7590),
              zoom: 14,
            ),
            onMapCreated: (gmaps.GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                 _mapController.complete(controller);
              }
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          if (instruction != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _mode == _MapMode.selectingOrigin ? Icons.my_location : Icons.pin_drop,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            instruction,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _cancelRoutePlanning,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_originId != null && _destId != null)
            _buildEstimationBar(isDark),

          // FABs
          Positioned(
            right: 20,
            bottom: (_originId != null && _destId != null) ? 280 : 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'myLocation',
                  onPressed: _showMyLocation,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primaryLight,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_mode != _MapMode.normal)
                  FloatingActionButton(
                    heroTag: 'cancelRoute',
                    onPressed: _cancelRoutePlanning,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    child: const Icon(Icons.close, color: Colors.white),
                  )
                else
                  FloatingActionButton.extended(
                    heroTag: 'planTrip',
                    onPressed: _startRoutePlanning,
                    label: Text(l10n.planTrip, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                    icon: const Icon(Icons.auto_awesome),
                    backgroundColor: AppColors.primary,
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
    final l10n = AppLocalizations.of(context);
    final estimates = TravelTimeService().estimate(_originId!, _destId!);
    final origin = allStations[_originId]!;
    final dest = allStations[_destId]!;
    final localeCode = ref.read(localeStringProvider);
    final originName = origin.nameForLocale(localeCode);
    final destName = dest.nameForLocale(localeCode);

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trip_origin_rounded, size: 20, color: AppColors.primaryLight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          originName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight.withOpacity(0.5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          destName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (estimates.isEmpty)
                    Text(l10n.noDirectRoute, style: const TextStyle(color: Colors.redAccent))
                  else
                    ...estimates.take(2).map((est) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.lineLabel(est.busLine),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '~${est.estimatedDuration.inMinutes} min',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryLight),
                                ),
                                Text(
                                  l10n.stopsLabel(est.stops.toString()),
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  // REPLACE the old Center(child: TextButton(...)) with this:
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _resetRoute,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(l10n.newRoute, style: const TextStyle(fontWeight: FontWeight.w700)),
                          style: TextButton.styleFrom(foregroundColor: isDark ? Colors.white54 : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 1. Set the active trip in the global state
                            ref.read(activeTripProvider.notifier).state =
                                ref.read(activeTripProvider).copyWith(
                                      originId: _originId,
                                      destinationId: _destId,
                                    );
                            
                            // 2. Save it to their trip history
                            ref.read(storageServiceProvider).addToHistory(TripHistoryEntry(
                              originId: _originId!,
                              destinationId: _destId!,
                              date: DateTime.now(),
                              busLineUsed: estimates.isNotEmpty ? estimates.first.busLine : null,
                            ));

                            // 3. Navigate to the Live GPS Tracking screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TripActiveScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions_bus_rounded, size: 18),
                          label: Text(l10n.takeThisBus, style: const TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBusDetails(Bus bus) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A241D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Line ${bus.lineNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (bus.delayMinutes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('Delayed ${bus.delayMinutes} min', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Text('On Time', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Heading to: ${bus.direction}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('NEXT STOP', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryLight),
                const SizedBox(width: 12),
                Expanded(child: Text(bus.nextStationName ?? 'Calculating...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(bus.remainingTimeSeconds / 60).ceil()} min', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('${(bus.remainingDistanceMeters / 1000).toStringAsFixed(1)} km', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showStationDetails(dynamic station) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find all live buses heading to this station
    final allBuses = ref.read(busesProvider).value ?? [];
    final incomingBuses = allBuses.where((b) => b.nextStationId == station.id).toList()
      ..sort((a, b) => a.remainingTimeSeconds.compareTo(b.remainingTimeSeconds));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A241D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station.nameForLocale(code), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${l10n.linesLabel(station.lineNumbers.join(", "))}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('INCOMING BUSES', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (incomingBuses.isEmpty)
               const Text('No buses approaching currently.', style: TextStyle(fontStyle: FontStyle.italic))
            else
              ...incomingBuses.map((bus) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(bus.lineNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(bus.direction, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${(bus.remainingTimeSeconds / 60).ceil()} min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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