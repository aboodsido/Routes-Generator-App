import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/route_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _distanceController = TextEditingController();

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final routeProvider = Provider.of<RouteProvider>(context);

    // Get current location if available
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
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter target distance (meters)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.purple.shade300)),
                      onPressed: () async {
                        double targetDistance =
                            double.tryParse(_distanceController.text) ?? 1000;
                        routeProvider.generateRoute(startPoint, targetDistance);

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
                    Text("Distance: ${_distanceController.text} m"),
                    // Text(
                    //     "Estimated Time: ${(walkingSpeed * _calculateDistance(routeProvider.routePoints) / 60).toStringAsFixed(1)} mins"),
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
