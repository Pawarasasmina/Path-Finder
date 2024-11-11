import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'page3.dart'; // Import Page3
import '../widgets/custom_app_bar.dart';

class Page2 extends StatelessWidget {
  final LatLng startLocation; // Starting location from Page1
  final LatLng destination; // Destination from Page1

  const Page2({
    Key? key,
    required this.startLocation,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger navigation to Page3 after the build completes
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Page3(startLocation: startLocation, destination: destination),
        ),
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        // Use Stack to layer the map and content
        children: [
          // Google Map widget
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: startLocation, // Start location for the camera
              zoom: 14.0, // Set zoom level
            ),
            mapType: MapType.normal, // Normal map type
            myLocationEnabled: true, // Enable location marker
            onMapCreated: (GoogleMapController controller) {
              // Optional: Add any custom logic after the map is created
            },
          ),
          // Blurred effect with BackdropFilter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(
                  0.5), // Optional: Dark overlay for better readability
            ),
          ),
          // Main content on top of the blurred map
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CircularProgressIndicator with cyan color
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 11, 227, 255)), // Cyan color
                ),
                const SizedBox(height: 20),
                Center(
                  // Center widget added here
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Checking Traffic Condition',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors
                                .white), // Change text color to white for visibility
                        textAlign: TextAlign
                            .center, // Ensure text alignment is centered
                      ),
                      SizedBox(height: 5), // Space between the two lines
                      Text(
                        'Fetching the Main Route...',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors
                                .white), // Change text color to white for visibility
                        textAlign: TextAlign
                            .center, // Ensure text alignment is centered
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
