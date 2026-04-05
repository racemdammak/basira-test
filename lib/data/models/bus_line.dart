class BusLine {
  final String id;
  final String lineNumber;
  final String directionFrom;
  final String directionTo;
  final List<String> stationIds;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int intervalMinutes;

  const BusLine({
    required this.id,
    required this.lineNumber,
    required this.directionFrom,
    required this.directionTo,
    required this.stationIds,
    this.startHour = 5,
    this.startMinute = 30,
    this.endHour = 22,
    this.endMinute = 0,
    this.intervalMinutes = 25,
  });

  List<DateTime> generateSchedule() {
    final schedule = <DateTime>[];
    final now = DateTime.now();
    var current = DateTime(now.year, now.month, now.day, startHour, startMinute);
    final end = DateTime(now.year, now.month, now.day, endHour, endMinute);

    while (current.isBefore(end)) {
      schedule.add(current);
      current = current.add(Duration(minutes: intervalMinutes));
    }
    return schedule;
  }

  DateTime? getNextDeparture() {
    final schedule = generateSchedule();
    final now = DateTime.now();
    for (final dep in schedule) {
      if (dep.isAfter(now)) return dep;
    }
    return null;
  }

  List<DateTime> getNextDepartures({int count = 5}) {
    final schedule = generateSchedule();
    final now = DateTime.now();
    final upcoming = schedule.where((d) => d.isAfter(now)).take(count).toList();
    return upcoming;
  }
}
