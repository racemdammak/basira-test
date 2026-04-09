import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteSegment {
  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;

  RouteSegment({required this.points, required this.distanceMeters, required this.durationSeconds});
}

class DirectionsService {
  static final DirectionsService instance = DirectionsService._internal();
  DirectionsService._internal();

  final Dio _dio = Dio();
  // Cache to prevent infinite Google Cloud billing
  final Map<String, RouteSegment> _cache = {};

  // TODO: Replace with your actual API key from your AndroidManifest
  final String _apiKey = "YOUR_GOOGLE_MAPS_API_KEY_HERE"; 

  Future<RouteSegment?> getRoute(LatLng origin, LatLng destination) async {
    final cacheKey = '${origin.latitude},${origin.longitude}_${destination.latitude},${destination.longitude}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$_apiKey';

      final response = await _dio.get(url);
      final data = response.data;

      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];
        
        final encodedPolyline = route['overview_polyline']['points'];
        final points = _decodePolyline(encodedPolyline);
        
        final segment = RouteSegment(
          points: points,
          distanceMeters: leg['distance']['value'],
          durationSeconds: leg['duration']['value'],
        );
        
        _cache[cacheKey] = segment;
        return segment;
      }
    } catch (e) {
      print("DirectionsService Error: $e");
    }
    return null;
  }

  // Decodes Google's compressed polyline string into coordinates
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}