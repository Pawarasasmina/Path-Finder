import 'dart:async'; // For Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../widgets/bottom_nav_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Declare the notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class last extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destination;

  last({required this.startLocation, required this.destination});

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<last> {
  late GoogleMapController _mapController;
  List<List<LatLng>> _routePoints = []; // List of routes
  List<String> _routeDescriptions = []; // Descriptions for routes
  String _trafficCondition = "Loading..."; // To store traffic condition
  String _duration = ""; // To store estimated time for the first route
  int _selectedRouteIndex = 0; // To keep track of the selected route
  Map<String, dynamic>? _routeData; // To store the fetched route data
  String _selectedRouteDetails = ""; // To show the selected route details
  bool _showRouteDetails = false; // To control the visibility of route details
  int _currentIndex = 1; // Track the current index of the BottomNavBar
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    // Initialize the notification settings here
    _initializeNotifications();
  }

  // Initialize the notification settings
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Use your app icon

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    _checkProximityToDestination();
  }

  // Function to calculate distance and trigger notification
  void _checkProximityToDestination() {
    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (distance <= 500) {
        _sendNotification(); // Trigger notification
        _showAlertNearDestination(); // Show alert dialog
      }
      if (distance <= 0) {
        _showSuccessAlert(); // Trigger notification
      }
    }
  }

  // Function to send notification
  Future<void> _sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel name
      channelDescription: 'your_channel_description', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Destination Alert', // Notification Title
      'You are approaching your destination.', // Notification Body
      platformChannelSpecifics,
      payload: 'destination_alert', // You can add custom payload if needed
    );
  }

  // Fetch route data and update traffic condition
  Future<void> _fetchRoute() async {
    final String googleApiKey = '';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&key=$googleApiKey&traffic_model=best_guess&departure_time=now&alternatives=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _routeData = data; // Store the fetched route data
        _parseRoutePoints(data);
        _getTrafficCondition(
            data, _selectedRouteIndex); // Update traffic condition
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch route')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching route')),
      );
    }
  }

  void _launchGoogleMaps() async {
    final String startLatitude = widget.startLocation.latitude.toString();
    final String startLongitude = widget.startLocation.longitude.toString();
    final String destinationLatitude = widget.destination.latitude.toString();
    final String destinationLongitude = widget.destination.longitude.toString();

    final String url =
        'https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Parse route points
  void _parseRoutePoints(Map<String, dynamic> data) {
    if (data['routes'].isNotEmpty) {
      setState(() {
        _routePoints.clear(); // Clear previous routes
        _routeDescriptions.clear(); // Clear previous descriptions
      });

      for (var route in data['routes']) {
        List<dynamic> steps = route['legs'][0]['steps'];
        List<LatLng> points = [];
        for (var step in steps) {
          String encodedPolyline = step['polyline']['points'];
          points.addAll(_decodePolyline(encodedPolyline));
        }
        setState(() {
          _routePoints.add(points); // Add each route to the list
          _routeDescriptions.add(route['summary']); // Add route description
        });
      }
    }
  }

  // Get traffic condition
  void _getTrafficCondition(Map<String, dynamic> data, int selectedIndex) {
    if (data['routes'].isNotEmpty) {
      int durationInTraffic = data['routes'][selectedIndex]['legs'][0]
          ['duration_in_traffic']['value'];
      int duration =
          data['routes'][selectedIndex]['legs'][0]['duration']['value'];

      setState(() {
        _trafficCondition =
            durationInTraffic > duration ? "Heavy Traffic" : "Low Traffic";
        _duration = (durationInTraffic / 60).round().toString() + " minutes";
      });
    }
  }

  // Function to show route details temporarily
  void _showRouteDetailsTemporarily(String details) {
    setState(() {
      _selectedRouteDetails = details;
      _showRouteDetails = true;
    });

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showRouteDetails = false; // Hide after 3 seconds
      });
    });
  }

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
      int dlat = (result >> 1) ^ -(result & 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result >> 1) ^ -(result & 1);
      lng += dlng;

      points.add(LatLng((lat / 1E5), (lng / 1E5)));
    }
    return points;
  }

// Your existing function that shows a popup alert
  void _showAlertNearDestination() {
    Future.delayed(const Duration(seconds: 5), () {
      // Send notification when the alert is triggered
      _sendNotification(); // Send the notification here

      // Show the alert dialog as before
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active, // Alert icon
                  color: Colors.amber,
                  size: 60, // Larger size for the alert icon
                ),
                const SizedBox(height: 10), // Space between icon and message
                const Text(
                  'Alert',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold), // Larger title font
                ),
              ],
            ),
            content: const Text(
              'You have to go!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center, // Center the message
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _showSuccessAlert(); // Show success alert after closing
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _showSuccessAlert() {
    // Delay for 5 seconds before showing the success alert
    Future.delayed(const Duration(seconds: 5), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle, // Success icon
                  color: Colors.green,
                  size: 60, // Larger size for the success icon
                ),
                const SizedBox(height: 10), // Space between icon and message
                const Text(
                  'Success!',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold), // Larger title font
                ),
              ],
            ),
            content: const Text(
              'You completed your journey!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center, // Center the message
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                  Navigator.pushReplacementNamed(
                      context, '/home'); // Navigate to home page
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    });
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
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
                    ),
                  },
                  polylines: _routePoints.isNotEmpty
                      ? {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            color: Colors.blue,
                            width: 4,
                            points: _routePoints[_selectedRouteIndex],
                          ),
                        }
                      : {},
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
                if (_showRouteDetails)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        _selectedRouteDetails,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF011A33), Color(0xFF000A14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _trafficCondition == "Heavy Traffic"
                          ? Icons.traffic
                          : Icons.directions_car,
                      color: _trafficCondition == "Heavy Traffic"
                          ? Colors.red
                          : Colors.green,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Traffic: $_trafficCondition\nEstimated Time: $_duration',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Ensure the row takes minimum space
                    children: [
                      // First FloatingActionButton with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF379D9D), // Start color
                              Color(0xFF4ECDC4), // End color
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle, // Ensures it remains circular
                        ),
                        child: FloatingActionButton(
                          onPressed: () {
                            _showAlertNearDestination(); // Start journey and show alert
                          },
                          child: const Icon(Icons.play_arrow),
                          backgroundColor:
                              Colors.transparent, // Make background transparent
                        ),
                      ),
                      const SizedBox(
                          width: 10), // Add spacing between the buttons
                      // Second FloatingActionButton with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF379D9D), // Start color
                              Color(0xFF4ECDC4), // End color
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle, // Ensures it remains circular
                        ),
                        child: FloatingActionButton(
                          onPressed: () {
                            _launchGoogleMaps(); // Launch Google Maps with the selected route
                          },
                          child: const Icon(Icons.directions),
                          backgroundColor:
                              Colors.transparent, // Make background transparent
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _routeDescriptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRouteIndex =
                                index; // Update selected route index
                            if (_routeData != null) {
                              _getTrafficCondition(_routeData!,
                                  index); // Update traffic condition
                              _showRouteDetailsTemporarily(_routeDescriptions[
                                  index]); // Show route details
                            }
                          });
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            gradient: _selectedRouteIndex == index
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF379D9D), // Start color
                                      Color(0xFF4ECDC4), // End color
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null, // Use null for gradient when not selected
                            color: _selectedRouteIndex != index
                                ? Colors.grey
                                    .shade200 // Fallback color if not selected
                                : null, // Use null when gradient is applied
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Route ${index + 1}', // Show only the route number
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _currentPosition {}
