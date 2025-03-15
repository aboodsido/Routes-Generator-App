import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../helpers/calculate_distances.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _timeController = TextEditingController();

  // Average walking speed in m/s (approx 1.4 m/s = ~5 km/h)
  final double averageWalkingSpeed = 1.4;

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final routeProvider = Provider.of<RouteProvider>(context);

    // Get current location if available, or fallback coordinates
    final currentLocation = locationProvider.currentLocation;
    final startPoint = currentLocation != null
        ? LatLng(currentLocation.latitude!, currentLocation.longitude!)
        : const LatLng(31.5225, 34.4531);

    // Set initial camera position
    CameraPosition initialCameraPosition =
        CameraPosition(target: startPoint, zoom: 16);

    // Create a polyline from route points
    Set<Polyline> polylines = {};
    if (routeProvider.routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("walking_route"),
          points: routeProvider.routePoints,
          color: Colors.purpleAccent,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        ),
      );
    }

    // Calculate the actual distance of the generated route
    double routeDistance = calculateTotalDistance(routeProvider.routePoints);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade300,
        title: const Text(
          'Walking Routes',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            polylines: polylines,
          ),
          // Input and generate button
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter walking time (minutes)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.purple.shade300),
                      ),
                      onPressed: () async {
                        // Parse entered time (in minutes) and convert to seconds
                        double targetTimeMinutes =
                            double.tryParse(_timeController.text) ?? 20;
                        double targetTimeSeconds = targetTimeMinutes * 60;
                        // Calculate the target distance using average walking speed
                        double targetDistance =
                            averageWalkingSpeed * targetTimeSeconds;

                        // Generate the route using the calculated target distance
                        await routeProvider.generateRoute(
                            startPoint, targetDistance);

                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(startPoint),
                        );
                      },
                      child: const Text('Generate Best Route'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display the actual route distance from the generated route
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Route Distance: ${routeDistance.toStringAsFixed(0)} m",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
