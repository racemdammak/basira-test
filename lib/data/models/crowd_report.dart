class CrowdReport {
  final String busId;
  final String? userId;
  final int reportedOccupancy;
  final DateTime timestamp;

  const CrowdReport({
    required this.busId,
    this.userId,
    required this.reportedOccupancy,
    required this.timestamp,
  });
}
