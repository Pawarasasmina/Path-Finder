import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'route.dart'; // Ensure this is correctly importing your Route page
import '../widgets/bottom_nav_bar.dart';

class Home extends StatefulWidget {
  final String startAddress;
  final String destinationAddress;

  Home({required this.startAddress, required this.destinationAddress});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? _mapController;
  LatLng? _startingLocation;
  LatLng? _destinationLocation;
  final TextEditingController _startingController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _startingController.text = widget.startAddress;
    _destinationController.text = widget.destinationAddress;

    // Resolve the starting and destination locations immediately
    _updateLocationFromCity(widget.startAddress, true);
    _updateLocationFromCity(widget.destinationAddress, false);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_startingLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_startingLocation!, 14.0),
      );
    }
  }

  void _navigateToDestination() {
    if (_startingLocation != null && _destinationLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_destinationLocation!, 14.0),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both locations.')),
      );
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/pathFinder');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
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
            _startingLocation = newLocation;
          } else {
            _destinationLocation = newLocation;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Path Finder',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w200,
            color: Color(0xFF379D9D),
            fontFamily: 'Alfa Slab One',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF011A33),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          if (_startingLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _startingLocation!,
                zoom: 14.0,
              ),
              onMapCreated: _onMapCreated,
              markers: _startingLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('startingLocation'),
                        position: _startingLocation!,
                        infoWindow:
                            const InfoWindow(title: 'Starting Location'),
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
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildTextField(
                  controller: _startingController,
                  label: 'Starting Location',
                  onChanged: (value) {
                    _updateLocationFromCity(value, true);
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _destinationController,
                  label: 'Destination',
                  onChanged: (value) {
                    _updateLocationFromCity(value, false);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_startingLocation != null &&
                        _destinationLocation != null) {
                      _navigateToDestination();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => route(
                            startLocation:
                                _startingLocation!, // Pass the starting location
                            destination:
                                _destinationLocation!, // Pass the destination
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select both locations.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    'Check Alternative Paths',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: const Color(0xFF379D9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF379D9D)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF379D9D), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF379D9D),
          ),
        ),
      ),
    );
  }
}
