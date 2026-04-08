import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/bus_line.dart';
import '../models/station.dart';

class CsvDataService {
  CsvDataService._();

  static final CsvDataService instance = CsvDataService._();

  final Map<String, Station> _allStations = {};
  final List<BusLine> _allBusLines = [];
  bool _initialized = false;

  Map<String, Station> get allStations {
    if (!_initialized) {
      throw StateError('CsvDataService is not initialized. Call initialize() before reading data.');
    }
    return _allStations;
  }

  List<BusLine> get allBusLines {
    if (!_initialized) {
      throw StateError('CsvDataService is not initialized. Call initialize() before reading data.');
    }
    return List.unmodifiable(_allBusLines);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final stationCsv = await rootBundle.loadString('assets/data/stations.csv');
    final busLineCsv = await rootBundle.loadString('assets/data/bus_lines.csv');

    final stations = _parseStations(stationCsv);
    final busLines = _parseBusLines(busLineCsv);

    _allStations
      ..clear()
      ..addEntries(stations.map((station) => MapEntry(station.id, station)));
    _allBusLines
      ..clear()
      ..addAll(busLines);
    _initialized = true;
  }

  List<Station> _parseStations(String csv) {
    final rows = const CsvToListConverter().convert(csv);
    if (rows.isEmpty) return [];
    final header = rows.first.map((value) => value.toString()).toList();
    return rows.skip(1).map((row) {
      final cells = row.map((value) => value.toString()).toList();
      final values = Map<String, String>.fromIterables(header, cells);
      return Station(
        id: values['id']!.trim(),
        nameAr: values['nameAr']!.trim(),
        nameFr: values['nameFr']!.trim(),
        nameTun: values['nameTun']!.trim(),
        coordinates: LatLng(
          double.parse(values['latitude']!.trim()),
          double.parse(values['longitude']!.trim()),
        ),
        lineNumbers: _splitList(values['lineNumbers']!.trim()),
      );
    }).toList();
  }

  List<BusLine> _parseBusLines(String csv) {
    final rows = const CsvToListConverter().convert(csv);
    if (rows.isEmpty) return [];
    final header = rows.first.map((value) => value.toString()).toList();
    return rows.skip(1).map((row) {
      final cells = row.map((value) => value.toString()).toList();
      final values = Map<String, String>.fromIterables(header, cells);
      return BusLine(
        id: values['id']!.trim(),
        lineNumber: values['lineNumber']!.trim(),
        directionFrom: values['directionFrom']!.trim(),
        directionTo: values['directionTo']!.trim(),
        stationIds: _splitList(values['stationIds']!.trim()),
        startHour: int.parse(values['startHour']!.trim()),
        startMinute: int.parse(values['startMinute']!.trim()),
        endHour: int.parse(values['endHour']!.trim()),
        endMinute: int.parse(values['endMinute']!.trim()),
        intervalMinutes: int.parse(values['intervalMinutes']!.trim()),
      );
    }).toList();
  }

  List<String> _splitList(String value) {
    if (value.isEmpty) return [];
    return value.split('|').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
  }
}
