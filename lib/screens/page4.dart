import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import '../screens/home.dart';
import '../screens/park_selection_screen.dart';
import '../widgets/custom_app_bar.dart';

class Page4 extends StatefulWidget {
  final List<LatLng> routePoints;

  const Page4({Key? key, required this.routePoints}) : super(key: key);

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  List<Map<String, dynamic>> trafficConditions = [];
  Set<Marker> _markers = {};
  String _startAddress = "";
  String _destinationAddress = "";

  @override
  void initState() {
    super.initState();
    _fetchLiveTrafficConditions();
    _fetchLocationNames();
    _setMarkers();
  }

  void _setMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('start_location'),
        position: widget.routePoints[0],
        infoWindow: const InfoWindow(title: 'Start Location'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('end_location'),
        position: widget.routePoints.last,
        infoWindow: const InfoWindow(title: 'End Location'),
      ),
    );

    _addRandomParkingLocations(widget.routePoints[0]);
  }

  void _addRandomParkingLocations(LatLng startLocation) {
    Random random = Random();
    int parkingCount = 5;

    for (int i = 0; i < parkingCount; i++) {
      double latitudeOffset = (random.nextDouble() - 0.5) * 0.01;
      double longitudeOffset = (random.nextDouble() - 0.5) * 0.01;

      LatLng parkingLocation = LatLng(
        startLocation.latitude + latitudeOffset,
        startLocation.longitude + longitudeOffset,
      );

      _markers.add(
        Marker(
          markerId: MarkerId('parking_$i'),
          position: parkingLocation,
          infoWindow: InfoWindow(title: 'Parking Location $i'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  Future<void> _fetchLocationNames() async {
    final apiKey = '';
    final startLatLng = widget.routePoints[0];
    final endLatLng = widget.routePoints.last;

    final startUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${startLatLng.latitude},${startLatLng.longitude}&key=$apiKey';
    final endUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${endLatLng.latitude},${endLatLng.longitude}&key=$apiKey';

    try {
      final startResponse = await http.get(Uri.parse(startUrl));
      final startData = json.decode(startResponse.body);

      final endResponse = await http.get(Uri.parse(endUrl));
      final endData = json.decode(endResponse.body);

      if (startData['status'] == 'OK' && endData['status'] == 'OK') {
        setState(() {
          _startAddress =
              _getCityName(startData['results'][0]['address_components']);
          _destinationAddress =
              _getCityName(endData['results'][0]['address_components']);
        });
      } else {
        print('Failed to fetch location names');
      }
    } catch (e) {
      print('Error fetching location names: $e');
    }
  }

  String _getCityName(List<dynamic> addressComponents) {
    for (var component in addressComponents) {
      if (component['types'].contains('locality') ||
          component['types'].contains('administrative_area_level_1')) {
        return component['long_name'];
      }
    }
    return 'Unknown City';
  }

  Future<void> _fetchLiveTrafficConditions() async {
    final apiKey =
        'AIzaSyACYdhAmCpmX-4GdQlyWI-FQxq-Be4DVmA'; // Replace with your actual API key
    if (widget.routePoints.isEmpty) {
      print('No route points provided.');
      return; // Exit if there are no route points
    }

    final origin =
        '${widget.routePoints[0].latitude},${widget.routePoints[0].longitude}';
    final destination =
        '${widget.routePoints.last.latitude},${widget.routePoints.last.longitude}';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey&departure_time=now&traffic_model=best_guess';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response Data: ${response.body}'); // Debugging output
        final data = json.decode(response.body);
        setState(() {
          trafficConditions = _parseTrafficData(data);
        });
      } else {
        print('Failed to load traffic data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching traffic data: $e');
    }
  }

  List<Map<String, dynamic>> _parseTrafficData(dynamic data) {
    List<Map<String, dynamic>> trafficList = [];

    // Check if routes are available in the response
    if (data['routes'] != null && data['routes'].isNotEmpty) {
      final route = data['routes'][0];

      // Check if legs are available in the route
      if (route['legs'] != null && route['legs'].isNotEmpty) {
        final leg = route['legs'][0];

        // Safely retrieve duration in traffic and normal duration
        final durationInTraffic = leg['duration_in_traffic']?['value'] ?? 0;
        final normalDuration =
            leg['duration']?['value'] ?? 1; // Ensure normalDuration is not 0

        // Calculate traffic severity based on the percentage increase in travel time
        double trafficIncrease =
            (durationInTraffic - normalDuration) / normalDuration;

        // Determine traffic conditions based on trafficIncrease
        if (trafficIncrease > 0.5) {
          trafficList.add(_buildTrafficCondition(
              "Next 5 Minutes",
              "Heavy Traffic",
              Colors.red,
              Icons.close,
              "Expect significant delays."));
          trafficList.add(_buildTrafficCondition(
              "Next 15 Minutes",
              "Heavy Traffic",
              Colors.red,
              Icons.close,
              "Heavy congestion ahead."));
          trafficList.add(_buildTrafficCondition(
              "Next 1 Hour",
              "Moderate Traffic",
              Colors.orange,
              Icons.warning,
              "Conditions may improve slightly."));
        } else if (trafficIncrease > 0.2) {
          trafficList.add(_buildTrafficCondition(
              "Next 5 Minutes",
              "Moderate Traffic",
              Colors.orange,
              Icons.warning,
              "Moderate delays expected."));
          trafficList.add(_buildTrafficCondition(
              "Next 15 Minutes",
              "Moderate Traffic",
              Colors.orange,
              Icons.warning,
              "Expect slight delays."));
          trafficList.add(_buildTrafficCondition("Next 1 Hour", "Light Traffic",
              Colors.green, Icons.check, "Conditions are improving."));
        } else {
          trafficList.add(_buildTrafficCondition(
              "Next 5 Minutes",
              "Light Traffic",
              Colors.green,
              Icons.check,
              "Smooth driving ahead."));
          trafficList.add(_buildTrafficCondition(
              "Next 15 Minutes",
              "Light Traffic",
              Colors.green,
              Icons.check,
              "Minimal delays expected."));
          trafficList.add(_buildTrafficCondition("Next 1 Hour", "Light Traffic",
              Colors.green, Icons.check, "Conditions are optimal."));
        }
      } else {
        // Fallback in case no legs data is available
        trafficList.add(_buildTrafficCondition(
            "No Data Available",
            "Legs Data Unavailable",
            Colors.grey,
            Icons.error,
            "Unable to fetch legs data."));
      }
    } else {
      // Fallback in case no routes data is available
      trafficList.add(_buildTrafficCondition(
          "No Data Available",
          "Traffic Data Unavailable",
          Colors.grey,
          Icons.error,
          "Unable to fetch traffic data."));
    }

    return trafficList;
  }

// Helper function to build traffic condition data
  Map<String, dynamic> _buildTrafficCondition(String time, String condition,
      Color color, IconData icon, String status) {
    return {
      'text': time,
      'condition': condition,
      'status': status,
      'color': color,
      'icon': icon,
    };
  }

  void _navigateToPage4() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          startAddress: _startAddress,
          destinationAddress: _destinationAddress,
        ),
      ),
    );
  }

  void _viewParkingSlots() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ParkSelection(), // Replace with your actual screen for parking selection
      ),
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
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.routePoints.isNotEmpty
                    ? widget.routePoints[0]
                    : LatLng(0, 0),
                zoom: 14.0,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('selected_route'),
                  points: widget.routePoints,
                  color: Colors.blue,
                  width: 5,
                ),
              },
              markers: _markers,
            ),
          ),
          Expanded(
            flex: 2, // Increased the flex to give more space to the traffic box
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.traffic_rounded, // Use the desired icon here
                        size: 16, // Set the size of the icon
                        color: Colors.black, // Set the color of the icon
                      ),
                      const SizedBox(
                          width:
                              8), // Add some spacing between the icon and the text
                      Expanded(
                        child: Text(
                          'Upcoming Traffic Preview',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Set the desired width
                    child: const Divider(color: Colors.black, thickness: 1),
                  ),
                  // Underline for end location
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.traffic, // Use the desired icon here
                        size: 16, // Set the size of the icon
                        color: Colors.black, // Set the color of the icon
                      ),
                      const SizedBox(
                          width:
                              8), // Add some spacing between the icon and the text
                      Expanded(
                        child: Text(
                          'View Upcoming Traffic from $_startAddress to $_destinationAddress',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // Enable horizontal scrolling
                      child: Row(
                        children: trafficConditions.map((trafficCondition) {
                          return Container(
                            width: MediaQuery.of(context).size.width *
                                0.25, // Each card takes up 25% of the screen width
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: trafficCondition['condition'] ==
                                      'Heavy Traffic'
                                  ? Colors.red
                                  : trafficCondition[
                                      'color'], // Set red color for heavy traffic
                              boxShadow: [
                                // Outer shadow
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.3), // Outer shadow color
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: Offset(
                                      0, 3), // Change position of the shadow
                                ),
                                // Inner shadow
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.1), // Inner shadow color
                                  spreadRadius: -5,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 0), // Change position of the shadow
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // heavy Traffic image
                                if (trafficCondition['condition'] ==
                                    'Heavy Traffic') ...[
                                  Opacity(
                                    opacity:
                                        0.2, // Set the opacity for the background image
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'lib/assets/high traffic.jpg'), // Update with your image path
                                          fit: BoxFit
                                              .cover, // Cover the entire container
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Mid Traffic image
                                if (trafficCondition['condition'] ==
                                    'Moderate Traffic') ...[
                                  Opacity(
                                    opacity:
                                        0.15, // Set the opacity for the background image
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'lib/assets/mid traffic.jpg'), // Update with your image path
                                          fit: BoxFit
                                              .cover, // Cover the entire container
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Low Traffic image
                                if (trafficCondition['condition'] ==
                                    'Light Traffic') ...[
                                  Opacity(
                                    opacity:
                                        0.2, // Set the opacity for the background image
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'lib/assets/low traffic.jpg'), // Update with your image path
                                          fit: BoxFit
                                              .cover, // Cover the entire container
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Main content over the image
                                Padding(
                                  // Add padding around the Column
                                  padding: const EdgeInsets.all(
                                      8.0), // Specify your desired padding
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon section
                                      Icon(
                                        trafficCondition['icon'],
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 15),

                                      // Traffic time section
                                      Text(
                                        trafficCondition['text'],
                                        style: const TextStyle(
                                          color: Colors.white, // Text color
                                          fontSize: 16, // Font size
                                          fontWeight: FontWeight
                                              .bold, // Makes the text bold
                                          fontStyle: FontStyle
                                              .italic, // Makes the text italic (optional)
                                          // Underline the text (optional)
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      // Traffic condition section
                                      Text(
                                        trafficCondition['condition'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      Text(
                                        trafficCondition['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
              color: Colors.black, thickness: 1), // Underline for end location
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _viewParkingSlots,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('View Parking Slots',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _navigateToPage4,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Use Alternatives',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
