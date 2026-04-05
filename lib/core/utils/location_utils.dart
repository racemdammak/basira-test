import 'package:latlong2/latlong.dart';

/// Linearly interpolate between two LatLng points.
LatLng interpolate(LatLng start, LatLng end, double progress) {
  progress = progress.clamp(0.0, 1.0);
  return LatLng(
    start.latitude + (end.latitude - start.latitude) * progress,
    start.longitude + (end.longitude - start.longitude) * progress,
  );
}

/// Haversine distance in meters.
double distanceBetween(LatLng a, LatLng b) {
  const distance = Distance();
  return distance.as(LengthUnit.Meter, a, b);
}
