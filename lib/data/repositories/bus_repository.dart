import '../models/bus.dart';
import '../models/bus_line.dart';
import '../models/station.dart';
import '../models/trip.dart';
import '../mock/buses_mock.dart';
import '../mock/stations_mock.dart';

class BusRepository {
  // In-memory buses that can be updated (e.g. crowd reports)
  final List<Bus> _liveBuses = [];
  DateTime _lastRefresh = DateTime(0);

  /// Returns current live buses. Regenerates mock data if stale (>30s).
  Future<List<Bus>> getBuses() async {
    if (DateTime.now().difference(_lastRefresh).inSeconds > 30) {
      _liveBuses.clear();
      _liveBuses.addAll(generateLiveBuses());
      _lastRefresh = DateTime.now();
    }
    return List.unmodifiable(_liveBuses);
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
    return allBusLines;
  }

  Future<List<Station>> getAllStations() async {
    return allStations.values.toList();
  }

  Future<Station?> getStationById(String id) async {
    return stationById(id);
  }

  Future<List<Station>> searchStations(String query) async {
    final q = query.toLowerCase();
    return allStations.values.where((s) {
      return s.nameFr.toLowerCase().contains(q) ||
          s.nameAr.contains(q) ||
          s.nameTun.contains(q) ||
          s.id.contains(q);
    }).toList();
  }

  /// Find a trip between origin and destination.
  Future<Trip?> findTrip(String originId, String destinationId) async {
    final origin = stationById(originId);
    final destination = stationById(destinationId);
    if (origin == null || destination == null) return null;

    // Check if any line serves both stations in order
    for (final line in allBusLines) {
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
    return null; // no direct line
  }

  Future<List<Bus>> getBusesForRoute(String originId, String destinationId) async {
    final trip = await findTrip(originId, destinationId);
    if (trip == null) return [];

    final buses = await getBuses();
    return buses
        .where((b) => trip.sections.any((s) => b.lineNumber == s.busLineNumber))
        .toList()
      ..sort((a, b) => a.nextDeparture.compareTo(b.nextDeparture));
  }

  Future<List<Trip>> findTripOptions(String originId, String destinationId) async {
    final trips = <Trip>[];

    // Direct routes
    for (final line in allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi != -1 && di != -1 && oi < di) {
        final origin = stationById(originId)!;
        final destination = stationById(destinationId)!;
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

    // Single-transfer routes
    for (final line1 in allBusLines) {
      final oi = line1.stationIds.indexOf(originId);
      if (oi == -1) continue;

      // Find transfer stations common to another line
      for (final transferId in line1.stationIds.skip(oi + 1)) {
        for (final line2 in allBusLines) {
          if (line2.id == line1.id) continue;
          final ti = line2.stationIds.indexOf(transferId);
          final di = line2.stationIds.indexOf(destinationId);
          if (ti != -1 && di != -1 && ti < di) {
            final origin = stationById(originId)!;
            final transfer = stationById(transferId)!;
            final destination = stationById(destinationId)!;
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
