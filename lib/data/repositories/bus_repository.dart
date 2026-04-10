import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../models/bus.dart';
import '../models/bus_line.dart';
import '../models/station.dart';
import '../models/trip.dart';
import '../services/csv_data_service.dart';
import '../../core/services/directions_service.dart'; 
import '../../core/utils/location_utils.dart'; 

class BusRepository {
  final List<Bus> _liveBuses = [];
  final CsvDataService _dataService = CsvDataService.instance;
  bool _dataLoaded = false;
  Timer? _simulationTimer;

  Future<void> _ensureDataLoaded() async {
    if (_dataLoaded) return;
    await _dataService.initialize();
    _dataLoaded = true;
    _initializeLiveBuses();
    
    // Start the 5-second GPS Simulation Engine
    _simulationTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
      _simulateGpsMovement();
    });
  }

  void _initializeLiveBuses() {
    _liveBuses.clear();
    final now = DateTime.now();

    for (final line in _dataService.allBusLines) {
      // FORCE SPAWN 3 buses per line regardless of the time of day
      for (var busIndex = 1; busIndex <= 3; busIndex++) {
        final origin = _dataService.allStations[line.stationIds.first]!;
        final occ = (line.lineNumber.hashCode + busIndex) % 40 + 20;
        final fakeDeparture = now.add(Duration(minutes: busIndex * 15)); // Guarantee a schedule

        _liveBuses.add(Bus(
          id: '${line.lineNumber}_$busIndex',
          lineNumber: line.lineNumber,
          direction: '${line.directionFrom} → ${line.directionTo}',
          capacity: 80,
          currentOccupancy: occ,
          currentPosition: origin.coordinates,
          nextStationId: line.stationIds.length > 1 ? line.stationIds[1] : null,
          nextDeparture: fakeDeparture,
          estimatedArrival: fakeDeparture.add(Duration(minutes: line.stationIds.length * 4)),
          rampAvailable: busIndex % 3 == 0,
          isLowFloor: busIndex % 2 == 0,
        ));
      }
    }
  }

  // ─────── "SUMMON" BUS TO APPROACH USER ───────
  void forceBusToApproach(String lineNumber, String targetStationId) {
    final line = _dataService.allBusLines.firstWhere((l) => l.lineNumber == lineNumber);
    final targetIdx = line.stationIds.indexOf(targetStationId);
    final targetStation = _dataService.allStations[targetStationId]!;

    try {
      final bus = _liveBuses.firstWhere((b) => b.lineNumber == lineNumber);
      
      LatLng startPos;
      if (targetIdx > 0) {
        final previousStationId = line.stationIds[targetIdx - 1];
        final previousStation = _dataService.allStations[previousStationId]!;
        // Place it 85% of the way to your station so it arrives very soon
        startPos = interpolate(previousStation.coordinates, targetStation.coordinates, 0.85);
      } else {
        // If you are at the very first station, just offset it slightly
        startPos = LatLng(targetStation.coordinates.latitude - 0.003, targetStation.coordinates.longitude - 0.003);
      }

      bus.currentPosition = startPos;
      bus.nextStationId = targetStationId;
      
      // CRITICAL FIX: We force a straight-line path to the origin. 
      // If we let Google Directions route from a random interpolated GPS point, 
      // it creates weird U-turns causing the bus to look like it's driving "away".
      bus.pathPoints = [startPos, targetStation.coordinates];
      bus.pathIndex = 0;
      
    } catch (_) {}
  }

  // ─────── THE GPS SIMULATION ENGINE ───────
  void _simulateGpsMovement() {
    if (_liveBuses.isEmpty) return;

    // 1. REVERTED SPEED! (8.33 m/s = approx 30 km/h)
    final double speedMetersPerSecond = 8.33; 
    final double distanceToMove = speedMetersPerSecond * 5; // Distance covered in 5 seconds

    for (var bus in _liveBuses) {
      if (bus.nextStationId == null) continue;

      final nextStation = _dataService.allStations[bus.nextStationId];
      if (nextStation == null) continue;

      // 2. Fetch the road curves if the bus doesn't know the path yet
      if (bus.pathPoints == null) {
        _fetchPathForBus(bus, nextStation.coordinates);
        continue; // Wait for Google to return the road path
      }

      // 3. Drive the bus along the road curves
      _moveBusAlongPath(bus, distanceToMove, nextStation);
    }
  }

  Future<void> _fetchPathForBus(Bus bus, LatLng destination) async {
    final route = await DirectionsService.instance.getRoute(
      gmaps.LatLng(bus.currentPosition.latitude, bus.currentPosition.longitude),
      gmaps.LatLng(destination.latitude, destination.longitude)
    );
    
    if (route != null && route.points.isNotEmpty) {
      bus.pathPoints = route.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      bus.pathIndex = 0;
    } else {
      // Fallback: Straight line if API fails
      bus.pathPoints = [bus.currentPosition, destination];
      bus.pathIndex = 0;
    }
  }

  void _moveBusAlongPath(Bus bus, double distanceToMove, Station nextStation) {
    if (bus.pathPoints == null || bus.pathIndex >= bus.pathPoints!.length - 1) {
      // Bus arrived at the station! Find the next one.
      bus.currentPosition = nextStation.coordinates;
      bus.pathPoints = null;
      bus.pathIndex = 0;
      _assignNextStation(bus);
      return;
    }

    double remainingMove = distanceToMove;
    
    // Drive the bus across the polyline nodes
    while (remainingMove > 0 && bus.pathIndex < bus.pathPoints!.length - 1) {
      LatLng p1 = bus.currentPosition;
      LatLng p2 = bus.pathPoints![bus.pathIndex + 1];
      double dist = distanceBetween(p1, p2);

      if (remainingMove >= dist) {
        // Bus passed this node, snap to it and keep moving
        remainingMove -= dist;
        bus.pathIndex++;
        bus.currentPosition = bus.pathPoints![bus.pathIndex];
      } else {
        // Bus is between two road nodes
        double progress = remainingMove / dist;
        bus.currentPosition = interpolate(p1, p2, progress);
        
        // Calculate the direction the bus is facing
        bus.heading = _calculateHeading(p1, p2);
        remainingMove = 0;
      }
    }

    // Update Live ETA
    double distToNext = distanceBetween(bus.currentPosition, nextStation.coordinates);
    bus.remainingDistanceMeters = distToNext.round();
    bus.remainingTimeSeconds = (distToNext / 8.33).round(); // Fixed calculation to use the original speed
    bus.nextStationName = nextStation.nameFr;
  }

  double _calculateHeading(LatLng start, LatLng end) {
    final lat1 = start.latitude * pi / 180;
    final lng1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lng2 = end.longitude * pi / 180;

    final dLng = lng2 - lng1;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  void _assignNextStation(Bus bus) {
    final line = _dataService.allBusLines.firstWhere((l) => l.lineNumber == bus.lineNumber);
    if (bus.nextStationId == null) return;
    
    final currentIndex = line.stationIds.indexOf(bus.nextStationId!);
    if (currentIndex != -1 && currentIndex + 1 < line.stationIds.length) {
      bus.nextStationId = line.stationIds[currentIndex + 1];
    } else {
      bus.nextStationId = null; 
      bus.remainingDistanceMeters = 0;
      bus.remainingTimeSeconds = 0;
    }
  }

  // --- STANDARD GETTERS ---
  Future<List<Bus>> getBuses() async {
    await _ensureDataLoaded();
    return List.unmodifiable(_liveBuses);
  }

  Future<Bus?> getBusById(String id) async {
    await _ensureDataLoaded();
    try { return _liveBuses.firstWhere((b) => b.id == id); } catch (_) { return null; }
  }

  Future<List<BusLine>> getBusLines() async {
    await _ensureDataLoaded();
    return List.unmodifiable(_dataService.allBusLines);
  }

  Future<List<Station>> getAllStations() async {
    await _ensureDataLoaded();
    return List.unmodifiable(_dataService.allStations.values.toList());
  }

  Future<Station?> getStationById(String id) async {
    await _ensureDataLoaded();
    return _dataService.allStations[id];
  }

  Future<List<Station>> searchStations(String query) async {
    await _ensureDataLoaded();
    final q = query.toLowerCase();
    return _dataService.allStations.values.where((s) =>
      s.nameFr.toLowerCase().contains(q) || s.nameAr.toLowerCase().contains(q) || s.nameTun.toLowerCase().contains(q) || s.id.contains(q)
    ).toList();
  }

  Future<Trip?> findTrip(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final origin = _dataService.allStations[originId];
    final dest = _dataService.allStations[destinationId];
    if (origin == null || dest == null) return null;

    for (final line in _dataService.allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi != -1 && di != -1 && oi < di) {
        return Trip(id: '${line.lineNumber}_trip', origin: origin, destination: dest, sections: [
            Section(busLineNumber: line.lineNumber, from: origin, to: dest, duration: Duration(minutes: (di - oi) * 5)),
        ]);
      }
    }
    return null;
  }

  Future<List<Bus>> getBusesForRoute(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final trip = await findTrip(originId, destinationId);
    if (trip == null) return [];
    return _liveBuses.where((b) => trip.sections.any((s) => b.lineNumber == s.busLineNumber)).toList()..sort((a, b) => a.nextDeparture.compareTo(b.nextDeparture));
  }

  Future<List<Trip>> findTripOptions(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final trips = <Trip>[];

    // 1. Search for DIRECT routes first
    for (final line in _dataService.allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi != -1 && di != -1 && oi != di) {
        trips.add(Trip(
          id: '${line.lineNumber}_direct',
          origin: _dataService.allStations[originId]!,
          destination: _dataService.allStations[destinationId]!,
          sections: [
            Section(
              busLineNumber: line.lineNumber,
              from: _dataService.allStations[originId]!,
              to: _dataService.allStations[destinationId]!,
              duration: Duration(minutes: (di - oi).abs() * 5),
            ),
          ],
        ));
      }
    }

    if (trips.isNotEmpty) return trips; // Prefer direct if available

    // 2. Search for 1-TRANSFER routes (Multi-leg)
    for (final line1 in _dataService.allBusLines) {
      final oi1 = line1.stationIds.indexOf(originId);
      if (oi1 == -1) continue;

      // Look at every station on Line 1 as a potential transfer point
      for (int i = 0; i < line1.stationIds.length; i++) {
        if (i == oi1) continue;
        final transferId = line1.stationIds[i];

        // Does Line 2 connect this transfer point to the destination?
        for (final line2 in _dataService.allBusLines) {
          if (line1.id == line2.id) continue;
          final ti2 = line2.stationIds.indexOf(transferId);
          final di2 = line2.stationIds.indexOf(destinationId);

          if (ti2 != -1 && di2 != -1 && ti2 != di2) {
            trips.add(Trip(
              id: '${line1.lineNumber}_${line2.lineNumber}_transfer',
              origin: _dataService.allStations[originId]!,
              destination: _dataService.allStations[destinationId]!,
              sections: [
                Section(
                  busLineNumber: line1.lineNumber,
                  from: _dataService.allStations[originId]!,
                  to: _dataService.allStations[transferId]!,
                  duration: Duration(minutes: (i - oi1).abs() * 5),
                ),
                Section(
                  busLineNumber: line2.lineNumber,
                  from: _dataService.allStations[transferId]!,
                  to: _dataService.allStations[destinationId]!,
                  duration: Duration(minutes: (di2 - ti2).abs() * 5),
                ),
              ],
            ));
          }
        }
      }
    }
    
    // Sort so the shortest journey is recommended first
    trips.sort((a, b) => a.sections.length.compareTo(b.sections.length));
    return trips;
  }

  Future<void> reportCrowd(String busId, int occupancy) async {
    try {
      final bus = _liveBuses.firstWhere((b) => b.id == busId);
      bus.currentOccupancy = occupancy.clamp(0, bus.capacity);
    } catch (_) {}
  }
}