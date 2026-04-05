import 'station.dart';

class Trip {
  final String id;
  final Station origin;
  final Station destination;
  final List<Section> sections;

  const Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.sections,
  });

  Duration get totalDuration {
    return sections.fold(
      Duration.zero,
      (prev, s) => prev + s.duration,
    );
  }
}

class Section {
  final String busLineNumber;
  final Station from;
  final Station to;
  final Duration duration;

  const Section({
    required this.busLineNumber,
    required this.from,
    required this.to,
    required this.duration,
  });
}
