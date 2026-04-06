import 'package:latlong2/latlong.dart';
import '../models/bus.dart';
import '../models/bus_line.dart';
import 'stations_mock.dart';

/// All bus lines with expanded station lists.
const List<BusLine> allBusLines = [
  BusLine(
    id: 'line_1',
    lineNumber: '1',
    directionFrom: 'Nassria',
    directionTo: 'Bab Bhar',
    stationIds: [
      'nassria',
      'jabri',
      'hached',
      'place_15_novembre',
      'centre_ville',
      'bab_jedid',
      'bab_bhar',
    ],
    startHour: 5,
    startMinute: 30,
    endHour: 22,
    endMinute: 0,
    intervalMinutes: 20,
  ),
  BusLine(
    id: 'line_2',
    lineNumber: '2',
    directionFrom: 'Sfax Sud',
    directionTo: 'Université',
    stationIds: [
      'sfax_sud',
      'cite_el_izdihar',
      'hopital_habib_bourguiba',
      'moussa_ibn_noussair',
      'hay_riadh',
      'cite_el_amal',
      'hopital_hedi_chaker',
      'universite',
    ],
    startHour: 5,
    startMinute: 45,
    endHour: 21,
    endMinute: 30,
    intervalMinutes: 25,
  ),
  BusLine(
    id: 'line_4',
    lineNumber: '4',
    directionFrom: 'Aéroport',
    directionTo: 'Médina',
    stationIds: [
      'aeroport',
      'cite_el_habib',
      'hopital_habib_bourguiba',
      'route_tunis',
      'place_15_novembre',
      'centre_ville',
      'medina',
    ],
    startHour: 6,
    startMinute: 0,
    endHour: 21,
    endMinute: 0,
    intervalMinutes: 30,
  ),
  BusLine(
    id: 'line_6',
    lineNumber: '6',
    directionFrom: 'Sakiet Ezzit',
    directionTo: 'Gare Routière',
    stationIds: [
      'sakiet_ezzit',
      'cite_ali_baba',
      'sakiet_eddaier',
      'soukra',
      'el_firdaous',
      'route_tunis',
      'hached',
      'gare_routiere',
    ],
    startHour: 5,
    startMinute: 30,
    endHour: 22,
    endMinute: 0,
    intervalMinutes: 20,
  ),
  BusLine(
    id: 'line_10',
    lineNumber: '10',
    directionFrom: 'Chihia',
    directionTo: 'Nassria',
    stationIds: [
      'chihia',
      'cite_el_oumma',
      'sfax_sud',
      'sfax_ville',
      'centre_ville',
      'nassria',
    ],
    startHour: 5,
    startMinute: 40,
    endHour: 21,
    endMinute: 40,
    intervalMinutes: 25,
  ),
  BusLine(
    id: 'line_15',
    lineNumber: '15',
    directionFrom: 'Hay Ennour',
    directionTo: 'Centre Ville',
    stationIds: [
      'hay_ennour',
      'cite_boudrak',
      'cite_ennour',
      'hay_wahat',
      'hay_riadh',
      'hopital_hedi_chaker',
      'place_municipale',
      'centre_ville',
    ],
    startHour: 6,
    startMinute: 0,
    endHour: 21,
    endMinute: 30,
    intervalMinutes: 30,
  ),
];

/// Generate live bus instances with simulated positions.
List<Bus> generateLiveBuses() {
  final buses = <Bus>[];
  final now = DateTime.now();

  for (final line in allBusLines) {
    var busIndex = 1;
    for (final dep in line.getNextDepartures(count: 3)) {
      final diffMin = dep.difference(now).inMinutes;
      final origin = allStations[line.stationIds.first]!;
      final dest = allStations[line.stationIds.last]!;

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
