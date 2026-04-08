import '../models/station.dart';
import '../services/csv_data_service.dart';

Map<String, Station> get allStations => CsvDataService.instance.allStations;

List<Station> getAllStations() => allStations.values.toList();

Station? stationById(String id) => allStations[id];
