import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll2;

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../core/services/directions_service.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/models/bus.dart';
import '../../l10n/app_localizations.dart';

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
  final Completer<gmaps.GoogleMapController> _mapController = Completer();
  final Set<gmaps.Polyline> _polylines = {};
  
  Timer? _updateTimer;
  bool _isFollowingBus = true;
  bool _hasAutoPopped = false; 

  gmaps.LatLng _convert(ll2.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    _initSimulation();
  }

  Future<void> _initSimulation() async {
    // 1. Force the engine to load buses FIRST
    final repo = ref.read(busRepositoryProvider);
    await repo.getBuses(); 

    // 2. Summon the bus to approach the user
    if (widget.busLine != null) {
       repo.forceBusToApproach(widget.busLine!, widget.originId);
       ref.invalidate(busesProvider); // Force immediate UI refresh
    }
    
    _fetchRealisticRoute();
    
    // 3. Start syncing
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) ref.invalidate(busesProvider);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRealisticRoute() async {
    final origin = allStations[widget.originId];
    final dest = allStations[widget.destinationId];
    if (origin == null || dest == null) return;

    try {
      final route = await DirectionsService.instance.getRoute(
        _convert(origin.coordinates),
        _convert(dest.coordinates),
      );

      if (route != null && mounted) {
        setState(() {
          _polylines.add(gmaps.Polyline(
            polylineId: const gmaps.PolylineId('live_route'),
            points: route.points,
            color: AppColors.primary,
            width: 6,
          ));
        });
      } else {
        throw Exception("Route not found");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _polylines.add(gmaps.Polyline(
            polylineId: const gmaps.PolylineId('fallback_route'),
            points: [_convert(origin.coordinates), _convert(dest.coordinates)],
            color: AppColors.primary,
            width: 5,
            patterns: [gmaps.PatternItem.dash(20), gmaps.PatternItem.gap(10)],
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final tripState = ref.watch(activeTripProvider);
    final origin = allStations[widget.originId];
    final dest = allStations[widget.destinationId];
    
    // Using .value directly fixes the Riverpod "flashing" bug during async reloads
    final busesList = ref.watch(busesProvider).value ?? [];
    Bus? trackedBus;

    if (busesList.isNotEmpty && widget.busLine != null) {
      try {
        trackedBus = busesList.firstWhere((b) => b.lineNumber == widget.busLine);
      } catch (_) {}
    }

    // ─── LOGIC: AUTO-POP WHEN BUS ARRIVES AT ORIGIN ───
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || trackedBus == null || _hasAutoPopped) return;

      if (!tripState.isBoarded) {
        final isVeryClose = trackedBus.nextStationId == widget.originId && trackedBus.remainingDistanceMeters <= 30;
        final hasPassedOrigin = trackedBus.nextStationId != widget.originId && trackedBus.pathIndex > 0;

        if (isVeryClose || hasPassedOrigin) {
          _hasAutoPopped = true; 
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.busArrived),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    final Set<gmaps.Marker> markers = {};
    if (origin != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('origin'),
        position: _convert(origin.coordinates),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
      ));
    }
    if (dest != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('destination'),
        position: _convert(dest.coordinates),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
      ));
    }
    if (trackedBus != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('live_bus'),
        position: _convert(trackedBus.currentPosition),
        rotation: trackedBus.heading,
        anchor: const Offset(0.5, 0.5),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow),
      ));

      if (_isFollowingBus) {
        _mapController.future.then((controller) {
          controller.animateCamera(
            gmaps.CameraUpdate.newCameraPosition(
              gmaps.CameraPosition(
                target: _convert(trackedBus!.currentPosition),
                zoom: 16.5,
                bearing: trackedBus.heading,
                tilt: 45,
              ),
            ),
          );
        });
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.liveTracking, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary.withOpacity(0.9),
        foregroundColor: Colors.white,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: origin != null ? _convert(origin.coordinates) : const gmaps.LatLng(34.7406, 10.7590),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController.complete(controller),
            markers: markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onCameraMoveStarted: () {
              setState(() => _isFollowingBus = false);
            },
          ),

          if (!_isFollowingBus && trackedBus != null)
            Positioned(
              top: 120,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() => _isFollowingBus = true);
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),

          Positioned(
            left: 16, right: 16, bottom: 32,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A241D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30, offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.lineLabel(widget.busLine ?? '?'), 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const Spacer(),
                        if (trackedBus != null && trackedBus.delayMinutes > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('Delayed ${trackedBus.delayMinutes} min', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    
                    if (trackedBus == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(strokeWidth: 2),
                            const SizedBox(width: 16),
                            Text(l10n.waitingForBus, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_bus, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tripState.isBoarded ? l10n.arrivingAt : l10n.approaching, 
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)
                                ),
                                Text(
                                  trackedBus.nextStationName ?? 'Calculating...',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(trackedBus.remainingTimeSeconds / 60).ceil()} min', 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)
                              ),
                              Text(
                                '${(trackedBus.remainingDistanceMeters / 1000).toStringAsFixed(1)} km', 
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}