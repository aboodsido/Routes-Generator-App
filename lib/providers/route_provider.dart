import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class RouteProvider extends ChangeNotifier {
  List<LatLng> _routePoints = [];

  List<LatLng> get routePoints => _routePoints;

  /// Generates a looped walking route based on user input (time/distance)
  Future<void> generateRoute(LatLng startPoint, double distanceMeters) async {
    _routePoints = [];

    LatLng waypoint1 = _generateRandomWaypoint(startPoint, distanceMeters / 3);
    LatLng waypoint2 = _generateRandomWaypoint(startPoint, distanceMeters / 3);


    // Fetch route segments:
    // 1. Start → Waypoint1
    List<LatLng> segment1 = await _getWalkingRoute(startPoint, waypoint1);

    // 2. Waypoint1 → Waypoint2
    List<LatLng> segment2 = await _getWalkingRoute(waypoint1, waypoint2);

    // 3. Waypoint2 → Start
    List<LatLng> segment3 = await _getWalkingRoute(waypoint2, startPoint);

    // Combine segments to form a loop
    _routePoints = [
      ...segment1,
      ...segment2,
      ...segment3,
    ];

    notifyListeners();
  }

  /// Generates a random waypoint within a given distance (in meters)
  LatLng _generateRandomWaypoint(LatLng origin, double maxDistance) {
    Random random = Random();
    double maxOffset =
        maxDistance / 111000; // Approximate conversion from meters to degrees

    double latOffset = (random.nextDouble() - 0.5) * maxOffset * 2;
    double lngOffset = (random.nextDouble() - 0.5) * maxOffset * 2;

    return LatLng(origin.latitude + latOffset, origin.longitude + lngOffset);
  }

  /// Fetches walking directions from Google Directions API
  Future<List<LatLng>> _getWalkingRoute(LatLng start, LatLng end) async {
    final url =
        Uri.parse("https://maps.googleapis.com/maps/api/directions/json?"
            "origin=${start.latitude},${start.longitude}"
            "&destination=${end.latitude},${end.longitude}"
            "&mode=walking"
            "&key=$apiKey");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _decodePolyline(data['routes'][0]['overview_polyline']['points']);
    } else {
      throw Exception("Failed to get route");
    }
  }

  /// Decodes polyline points into a list of LatLng
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
