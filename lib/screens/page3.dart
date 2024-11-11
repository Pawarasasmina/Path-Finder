import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'package:geolocator/geolocator.dart'; // Import for location fetching
import 'package:geocoding/geocoding.dart'; // Import for geocoding
import 'page4.dart'; // Import the Page4 file
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class Page3 extends StatefulWidget {
  final LatLng startLocation; // Starting location from Page1
  final LatLng destination; // Destination from Page1

  const Page3({
    Key? key,
    required this.startLocation,
    required this.destination,
  }) : super(key: key);

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = []; // To store the route points
  String _startAddress = ""; // To store the start address
  String _destinationAddress = ""; // To store the destination address

  @override
  void initState() {
    super.initState();
    _fetchRoute(); // Fetch the route when the widget is initialized
    _getAddresses(); // Fetch the addresses for start and destination
  }

  Future<void> _getAddresses() async {
    try {
      // Fetch start address
      List<Placemark> startPlacemarks = await placemarkFromCoordinates(
        widget.startLocation.latitude,
        widget.startLocation.longitude,
      );
      if (startPlacemarks.isNotEmpty) {
        setState(() {
          _startAddress =
              "${startPlacemarks[0].locality}, ${startPlacemarks[0].country}"; // Get the city and country
        });
      }

      // Fetch destination address
      List<Placemark> destinationPlacemarks = await placemarkFromCoordinates(
        widget.destination.latitude,
        widget.destination.longitude,
      );
      if (destinationPlacemarks.isNotEmpty) {
        setState(() {
          _destinationAddress =
              "${destinationPlacemarks[0].locality}, ${destinationPlacemarks[0].country}"; // Get the city and country
        });
      }
    } catch (e) {
      print("Error fetching addresses: $e");
    }
  }

  Future<void> _fetchRoute() async {
    const String apiKey = ''; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          _decodePoly(data['routes'][0]['overview_polyline']['points']);
          _moveCamera(); // Move the camera to the center of the route
        } else {
          print('No routes found');
        }
      } else {
        throw Exception('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  void _moveCamera() {
    if (_routePoints.isNotEmpty) {
      LatLngBounds bounds = _calculateBounds(_routePoints);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double south = points[0].latitude;
    double north = points[0].latitude;
    double east = points[0].longitude;
    double west = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  void _decodePoly(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, result = 0, shift = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ (~(result & 1) + 1));
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ (~(result & 1) + 1));
      lng += dlng;

      LatLng point = LatLng((lat / 1E5), (lng / 1E5));
      points.add(point);
    }

    setState(() {
      _routePoints = points; // Update the route points
    });
  }

  void _navigateToPage4() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Page4(
          routePoints: _routePoints, // Pass the route points to Page4
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller; // Save the map controller
                  },
                  initialCameraPosition: CameraPosition(
                    target: widget.startLocation,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('start'),
                      position: widget.startLocation,
                      infoWindow: const InfoWindow(title: 'Start Location'),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: widget.destination,
                      infoWindow: const InfoWindow(title: 'Destination'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: _routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Start Location',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                                const BorderSide(color: Colors.green, width: 2),
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(text: _startAddress),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        readOnly: true,
                        controller:
                            TextEditingController(text: _destinationAddress),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _navigateToPage4,
                      icon: const Icon(Icons.directions_car,
                          color: Colors.white), // Add a car icon
                      label: const Text(
                        'Check Traffic Condition',
                        style: TextStyle(
                          color: Colors.white, // Text color set to white
                          fontSize: 18.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Button color set to blue
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
