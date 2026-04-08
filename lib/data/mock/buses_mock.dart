import 'package:latlong2/latlong.dart';
import '../models/bus.dart';
import '../models/bus_line.dart';
import '../services/csv_data_service.dart';

List<BusLine> get allBusLines => CsvDataService.instance.allBusLines;

/// Generate live bus instances with simulated positions.
List<Bus> generateLiveBuses() {
  final buses = <Bus>[];
  final now = DateTime.now();

  for (final line in allBusLines) {
    var busIndex = 1;
    for (final dep in line.getNextDepartures(count: 3)) {
      final diffMin = dep.difference(now).inMinutes;
      final origin = CsvDataService.instance.allStations[line.stationIds.first]!;
      final dest = CsvDataService.instance.allStations[line.stationIds.last]!;

      // Simulate position: if bus has departed, interpolate
      LatLng pos;
      if (diffMin <= 0) {
        // Already departed — rough interpolation
        final elapsed = -diffMin;
        final totalTrip = line.stationIds.length * 5; // ~5 min per segment
        final progress = (elapsed / totalTrip).clamp(0.0, 1.0);
        pos = LatLng(
          origin.coordinates.latitude +
              (dest.coordinates.latitude - origin.coordinates.latitude) * progress,
          origin.coordinates.longitude +
              (dest.coordinates.longitude - origin.coordinates.longitude) * progress,
        );
      } else {
        // At origin station
        pos = origin.coordinates;
      }

      final occ = (line.lineNumber.hashCode + busIndex) % 40 + 20; // 20-59

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
