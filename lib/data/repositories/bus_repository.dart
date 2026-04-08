import 'package:latlong2/latlong.dart';

import '../models/bus.dart';
import '../models/bus_line.dart';
import '../models/station.dart';
import '../models/trip.dart';
import '../services/csv_data_service.dart';

class BusRepository {
  // In-memory buses that can be updated (e.g. crowd reports)
  final List<Bus> _liveBuses = [];
  DateTime _lastRefresh = DateTime(0);
  final CsvDataService _dataService = CsvDataService.instance;
  bool _dataLoaded = false;

  Future<void> _ensureDataLoaded() async {
    if (_dataLoaded) return;
    await _dataService.initialize();
    _dataLoaded = true;
  }

  /// Returns current live buses. Regenerates mock data if stale (>30s).
  Future<List<Bus>> getBuses() async {
    await _ensureDataLoaded();
    if (DateTime.now().difference(_lastRefresh).inSeconds > 30) {
      _liveBuses.clear();
      _liveBuses.addAll(_generateLiveBuses());
      _lastRefresh = DateTime.now();
    }
    return List.unmodifiable(_liveBuses);
  }

  List<Bus> _generateLiveBuses() {
    final buses = <Bus>[];
    final now = DateTime.now();

    for (final line in _dataService.allBusLines) {
      var busIndex = 1;
      for (final dep in line.getNextDepartures(count: 3)) {
        final diffMin = dep.difference(now).inMinutes;
        final origin = _dataService.allStations[line.stationIds.first]!;
        final dest = _dataService.allStations[line.stationIds.last]!;

        // Simulate position: if bus has departed, interpolate
        final LatLng pos = diffMin <= 0
            ? LatLng(
                origin.coordinates.latitude +
                    (dest.coordinates.latitude - origin.coordinates.latitude) *
                        (-diffMin / (line.stationIds.length * 5)).clamp(0.0, 1.0),
                origin.coordinates.longitude +
                    (dest.coordinates.longitude - origin.coordinates.longitude) *
                        (-diffMin / (line.stationIds.length * 5)).clamp(0.0, 1.0),
              )
            : origin.coordinates;

        final occ = (line.lineNumber.hashCode + busIndex) % 40 + 20;

        buses.add(Bus(
          id: '${line.lineNumber}_$busIndex',
          lineNumber: line.lineNumber,
          direction: '${line.directionFrom} → ${line.directionTo}',
          capacity: 80,
          currentOccupancy: occ,
          currentPosition: pos,
          nextDeparture: dep,
          estimatedArrival: dep.add(Duration(minutes: line.stationIds.length * 4)),
          rampAvailable: busIndex % 3 == 0,
          isLowFloor: busIndex % 2 == 0,
        ));
        busIndex++;
      }
    }

    return buses;
  }

  Future<Bus?> getBusById(String id) async {
    final buses = await getBuses();
    try {
      return buses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
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
    return _dataService.allStations.values.where((s) {
      return s.nameFr.toLowerCase().contains(q) ||
          s.nameAr.toLowerCase().contains(q) ||
          s.nameTun.toLowerCase().contains(q) ||
          s.id.contains(q);
    }).toList();
  }

  /// Find a trip between origin and destination.
  Future<Trip?> findTrip(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final origin = _dataService.allStations[originId];
    final destination = _dataService.allStations[destinationId];
    if (origin == null || destination == null) return null;

    for (final line in _dataService.allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi != -1 && di != -1 && oi < di) {
        return Trip(
          id: '${line.lineNumber}_trip',
          origin: origin,
          destination: destination,
          sections: [
            Section(
              busLineNumber: line.lineNumber,
              from: origin,
              to: destination,
              duration: Duration(minutes: (di - oi) * 5),
            ),
          ],
        );
      }
    }
    return null;
  }

  Future<List<Bus>> getBusesForRoute(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final trip = await findTrip(originId, destinationId);
    if (trip == null) return [];

    final buses = await getBuses();
    return buses
        .where((b) => trip.sections.any((s) => b.lineNumber == s.busLineNumber))
        .toList()
      ..sort((a, b) => a.nextDeparture.compareTo(b.nextDeparture));
  }

  Future<List<Trip>> findTripOptions(String originId, String destinationId) async {
    await _ensureDataLoaded();
    final trips = <Trip>[];

    for (final line in _dataService.allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi != -1 && di != -1 && oi < di) {
        final origin = _dataService.allStations[originId]!;
        final destination = _dataService.allStations[destinationId]!;
        trips.add(Trip(
          id: '${line.lineNumber}_direct',
          origin: origin,
          destination: destination,
          sections: [
            Section(
              busLineNumber: line.lineNumber,
              from: origin,
              to: destination,
              duration: Duration(minutes: (di - oi) * 5),
            ),
          ],
        ));
      }
    }

    for (final line1 in _dataService.allBusLines) {
      final oi = line1.stationIds.indexOf(originId);
      if (oi == -1) continue;

      for (final transferId in line1.stationIds.skip(oi + 1)) {
        for (final line2 in _dataService.allBusLines) {
          if (line2.id == line1.id) continue;
          final ti = line2.stationIds.indexOf(transferId);
          final di = line2.stationIds.indexOf(destinationId);
          if (ti != -1 && di != -1 && ti < di) {
            final origin = _dataService.allStations[originId]!;
            final transfer = _dataService.allStations[transferId]!;
            final destination = _dataService.allStations[destinationId]!;
            trips.add(Trip(
              id: '${line1.lineNumber}_${line2.lineNumber}_transfer',
              origin: origin,
              destination: destination,
              sections: [
                Section(
                  busLineNumber: line1.lineNumber,
                  from: origin,
                  to: transfer,
                  duration: Duration(minutes: (ti - oi) * 5),
                ),
                Section(
                  busLineNumber: line2.lineNumber,
                  from: transfer,
                  to: destination,
                  duration: Duration(minutes: (di - ti) * 5),
                ),
              ],
            ));
          }
        }
      }
    }

    return trips;
  }

  Future<void> reportCrowd(String busId, int occupancy) async {
    try {
      final bus = _liveBuses.firstWhere((b) => b.id == busId);
      bus.currentOccupancy = occupancy.clamp(0, bus.capacity);
    } catch (_) {}
  }
}
