import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/csv_data_service.dart';

/// Service that estimates travel time & fare between two stations.
class TravelTimeEstimate {
  final String busLine;
  final int stops;
  final Duration estimatedDuration;
  final String originName;
  final String destinationName;

  const TravelTimeEstimate({
    required this.busLine,
    required this.stops,
    required this.estimatedDuration,
    required this.originName,
    required this.destinationName,
  });

  String get formattedTime => '${estimatedDuration.inMinutes} min';
  String get formattedFare => '0.50 TND'; // Standard fare for all routes
}

class TravelTimeService {
  List<TravelTimeEstimate> estimate(String originId, String destinationId) {
    final results = <TravelTimeEstimate>[];

    for (final line in CsvDataService.instance.allBusLines) {
      final oi = line.stationIds.indexOf(originId);
      final di = line.stationIds.indexOf(destinationId);
      if (oi == -1 || di == -1 || oi == di) continue;

      final stops = (di - oi).abs();
      final minutes = stops * 5; // ~5 min between stops

      final origin = CsvDataService.instance.allStations[originId];
      final destination = CsvDataService.instance.allStations[destinationId];

      results.add(TravelTimeEstimate(
        busLine: line.lineNumber,
        stops: stops,
        estimatedDuration: Duration(minutes: minutes),
        originName: origin?.nameFr ?? originId,
        destinationName: destination?.nameFr ?? destinationId,
      ));
    }

    return results;
  }

  /// Quick estimate for a single line
  TravelTimeEstimate? estimateQuick(String lineId, String originId, String destinationId) {
    final line = CsvDataService.instance.allBusLines.firstWhere(
      (l) => l.id == lineId,
      orElse: () => throw Exception('Line not found: $lineId'),
    );
    final oi = line.stationIds.indexOf(originId);
    final di = line.stationIds.indexOf(destinationId);
    if (oi == -1 || di == -1 || oi == di) return null;

    final stops = (di - oi).abs();
    final origin = CsvDataService.instance.allStations[originId];
    final destination = CsvDataService.instance.allStations[destinationId];

    return TravelTimeEstimate(
      busLine: line.lineNumber,
      stops: stops,
      estimatedDuration: Duration(minutes: stops * 5),
      originName: origin?.nameFr ?? originId,
      destinationName: destination?.nameFr ?? destinationId,
    );
  }
}

final travelTimeServiceProvider = Provider<TravelTimeService>((ref) {
  return TravelTimeService();
});

final travelEstimateProvider = Provider.family<
    List<TravelTimeEstimate>, ({String originId, String destinationId})>(
  (ref, params) => ref.watch(travelTimeServiceProvider).estimate(
    params.originId,
    params.destinationId,
  ),
);
