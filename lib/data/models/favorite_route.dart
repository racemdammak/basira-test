class FavoriteRoute {
  final String id;
  final String originId;
  final String destinationId;
  final String? name;
  final DateTime createdAt;

  const FavoriteRoute({
    required this.id,
    required this.originId,
    required this.destinationId,
    this.name,
    required this.createdAt,
  });

  FavoriteRoute copyWith({String? name}) {
    return FavoriteRoute(
      id: id,
      originId: originId,
      destinationId: destinationId,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }
}

class TripHistoryEntry {
  final String originId;
  final String destinationId;
  final DateTime date;
  final String? busLineUsed;

  const TripHistoryEntry({
    required this.originId,
    required this.destinationId,
    required this.date,
    this.busLineUsed,
  });
}

class CrowdReport {
  final String busLine;
  final int occupancy;
  final DateTime timestamp;

  const CrowdReport({
    required this.busLine,
    required this.occupancy,
    required this.timestamp,
  });
}

class DelayReport {
  final String busLine;
  final String stationId;
  final int delayMinutes;
  final DateTime timestamp;

  const DelayReport({
    required this.busLine,
    required this.stationId,
    required this.delayMinutes,
    required this.timestamp,
  });
}
