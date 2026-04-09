import 'package:latlong2/latlong.dart';

class Bus {
  final String id;
  final String lineNumber;
  final String direction;
  final int capacity;
  int currentOccupancy;
  LatLng currentPosition;
  
  // --- GPS Tracking Properties ---
  double heading; 
  int delayMinutes; 
  String? nextStationId; 
  String? nextStationName;
  int remainingDistanceMeters;
  int remainingTimeSeconds;

  // --- Road Pathing ---
  List<LatLng>? pathPoints;
  int pathIndex;

  final DateTime nextDeparture;
  final DateTime estimatedArrival;
  final bool rampAvailable;
  final bool isLowFloor;

  Bus({
    required this.id,
    required this.lineNumber,
    required this.direction,
    required this.capacity,
    required this.currentOccupancy,
    required this.currentPosition,
    this.heading = 0.0,
    this.delayMinutes = 0,
    this.nextStationId,
    this.nextStationName,
    this.remainingDistanceMeters = 0,
    this.remainingTimeSeconds = 0,
    this.pathPoints,
    this.pathIndex = 0,
    required this.nextDeparture,
    required this.estimatedArrival,
    this.rampAvailable = false,
    this.isLowFloor = false,
  });

  double get occupancyRatio => currentOccupancy / capacity;
  bool get isFull => currentOccupancy >= capacity;

  String get occupancyLabel {
    final ratio = occupancyRatio;
    if (ratio >= 0.95) return 'full';
    if (ratio >= 0.7) return 'crowded';
    return 'available';
  }
}