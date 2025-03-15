import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class RouteProvider extends ChangeNotifier {
  List<LatLng> _routePoints = [];

  List<LatLng> get routePoints => _routePoints;

  /// Generates a looped walking route based on user input
  Future<void> generateRoute(LatLng startPoint, double distanceMeters) async {
    _routePoints = [];

    // Generate a Random Waypoint within a Distance Range
    LatLng waypoint = _generateRandomWaypoint(startPoint, distanceMeters / 2);

    // Fetch Outward Route (Start → Waypoint)
    List<LatLng> outRoute = await _getWalkingRoute(startPoint, waypoint);

    // Fetch Return Route (Waypoint → Start)
    List<LatLng> returnRoute = await _getWalkingRoute(waypoint, startPoint);

    // Combine the Two Paths into One Loop
    _routePoints.addAll(outRoute);
    _routePoints.addAll(returnRoute);

    notifyListeners();
  }

  /// Generates a random waypoint within a given distance
  LatLng _generateRandomWaypoint(LatLng origin, double maxDistance) {
    Random random = Random();

    // Convert max distance to degrees (approximation)
    double maxOffset = maxDistance / 111000; // 1 degree ≈ 111 km

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
