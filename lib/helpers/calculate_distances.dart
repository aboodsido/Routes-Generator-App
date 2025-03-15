import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistanceBetween(LatLng a, LatLng b) {
  const double R = 6371000; // Radius of Earth in meters
  double lat1 = a.latitude * pi / 180;
  double lat2 = b.latitude * pi / 180;
  double deltaLat = (b.latitude - a.latitude) * pi / 180;
  double deltaLng = (b.longitude - a.longitude) * pi / 180;

  double aVal = sin(deltaLat / 2) * sin(deltaLat / 2) +
      cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
  double cVal = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
  return R * cVal;
}

double calculateTotalDistance(List<LatLng> points) {
  double totalDistance = 0.0;
  for (int i = 0; i < points.length - 1; i++) {
    totalDistance += calculateDistanceBetween(points[i], points[i + 1]);
  }
  return totalDistance;
}
