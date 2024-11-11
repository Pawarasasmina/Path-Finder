import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'page2.dart';
import '../widgets/custom_app_bar.dart';

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  final TextEditingController _startingController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(0.0, 0.0), 2.0),
    );
  }

  Future<void> _getCurrentLocation() async {
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Fetching Current Location..."),
            ],
          ),
        );
      },
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _startingController.text = 'Current Location';
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _navigateToDestination() {
    if (_destinationLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_destinationLocation!, 14.0),
      );
    }
  }

  Future<void> _updateLocationFromCity(
      String cityName, bool isStartingLocation) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        LatLng newLocation =
            LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          if (isStartingLocation) {
            _currentLocation = newLocation;
            _startingController.text = cityName;
          } else {
            _destinationLocation = newLocation;
            _destinationController.text = cityName;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location found for this city')),
        );
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input Error'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error, color: Colors.red), // Error icon
              SizedBox(width: 8),
              Expanded(
                  child: Text('Enter Locations Properly')), // Error message
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 2.0,
            ),
            onMapCreated: _onMapCreated,
            markers: _currentLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: _currentLocation!,
                      infoWindow: const InfoWindow(title: 'Current Location'),
                    ),
                    if (_destinationLocation != null)
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: _destinationLocation!,
                        infoWindow: const InfoWindow(title: 'Destination'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                      ),
                  }
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _startingController,
                          label: 'Starting Location',
                          onChanged: (value) {
                            _updateLocationFromCity(value, true);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () {
                          _getCurrentLocation();
                        },
                        tooltip: 'Get My Location',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _destinationController,
                    label: 'Destination',
                    onChanged: (value) {
                      _updateLocationFromCity(value, false);
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Validation check for starting and destination locations
                      if (_startingController.text.isEmpty ||
                          _destinationController.text.isEmpty) {
                        _showErrorDialog(); // Show error dialog if locations are empty
                        return; // Exit the onPressed function
                      }

                      // Navigate to the destination if both locations are entered
                      _navigateToDestination();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Page2(
                            startLocation: _currentLocation!,
                            destination: _destinationLocation!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black54,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.directions, size: 24.0),
                        SizedBox(width: 8),
                        Text(
                          'Show me the Route',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
