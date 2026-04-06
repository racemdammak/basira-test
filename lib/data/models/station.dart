import 'package:latlong2/latlong.dart';

class Station {
  final String id;
  final String nameAr;
  final String nameFr;
  final String nameTun;
  final LatLng coordinates;
  final List<String> lineNumbers;

  const Station({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameTun,
    required this.coordinates,
    required this.lineNumbers,
  });

  String nameForLocale(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr;
      case 'fr':
        return nameFr;
      default:
        return nameFr;
    }
  }

  Station copyWith({List<String>? lineNumbers}) {
    return Station(
      id: id,
      nameAr: nameAr,
      nameFr: nameFr,
      nameTun: nameTun,
      coordinates: coordinates,
      lineNumbers: lineNumbers ?? this.lineNumbers,
    );
  }
}
