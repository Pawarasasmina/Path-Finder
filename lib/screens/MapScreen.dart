import 'dart:convert'; // Import for JSON decoding
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import '../widgets/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import 'package:geolocator/geolocator.dart'; // Import for Geolocation
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MapModelScreen extends StatefulWidget {
  get destination => null;

  @override
  _MapModelScreenState createState() => _MapModelScreenState();
}

class _MapModelScreenState extends State<MapModelScreen> {
  late GoogleMapController mapController;
  int _currentIndex = 1;
  late String startingLocation;
  late LatLng startingCoordinates;
  Set<Polyline> _polylines = {}; // Set to hold polyline data
  String? _distance; // Variable to hold distance
  String? _duration; // Variable to hold duration
  LatLng? currentloc;
  Position? _currentPosition;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final LatLng SLiITMalabe =
      LatLng(6.9154633, 79.9724839); // SLiIT Malabe coordinates

  final Map<String, LatLng> locationCoordinates = {
    'Kothalawala': LatLng(6.9195897, 79.9714376),
    'Pettah': LatLng(6.9355, 79.8503),
    'Fort': LatLng(6.9330, 79.8500),
    'Mount Lavinia': LatLng(6.8290, 79.8636),
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestLocationPermission();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permissions granted
    } else {
      // Handle permissions denied
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Use your app's icon here

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null, // Add iOS settings if needed
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showDistanceDialog() {
    Future.delayed(const Duration(seconds: 5), () {
      // Show the notification
      _showNotification();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                Color.fromARGB(255, 85, 105, 218), // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning,
                    color: Colors.yellow, size: 50), // Larger attention mark
                SizedBox(height: 10), // Space between icon and text
                Text(
                  'Attention!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0), // Padding for the content
              child: Text(
                '500m more for our destination.',
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Show the second dialog after a delay of 3 seconds

                  _showArrivalDialog(); // Call the method to show the arrival dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your channel ID
      'your_channel_name', // Replace with your channel name
      channelDescription:
          'your_channel_description', // Description of the channel
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Attention!', // Notification title
      '500m more for our destination.', // Notification body
      platformChannelSpecifics,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getDirections(); // Fetch directions when the map is created
  }

  void _fitPolyLines() {
    if (_polylines.isNotEmpty) {
      // Create a LatLngBounds object
      LatLngBounds bounds;

      // Initialize bounds with the first polyline point
      LatLng firstPoint = _polylines.first.points.first;
      LatLng lastPoint = _polylines.first.points.last;

      bounds = LatLngBounds(
        northeast: LatLng(
          firstPoint.latitude > lastPoint.latitude
              ? firstPoint.latitude
              : lastPoint.latitude,
          firstPoint.longitude > lastPoint.longitude
              ? firstPoint.longitude
              : lastPoint.longitude,
        ),
        southwest: LatLng(
          firstPoint.latitude < lastPoint.latitude
              ? firstPoint.latitude
              : lastPoint.latitude,
          firstPoint.longitude < lastPoint.longitude
              ? firstPoint.longitude
              : lastPoint.longitude,
        ),
      );

      for (Polyline polyline in _polylines) {
        for (LatLng point in polyline.points) {
          bounds = LatLngBounds(
            northeast: LatLng(
              bounds.northeast.latitude > point.latitude
                  ? bounds.northeast.latitude
                  : point.latitude,
              bounds.northeast.longitude > point.longitude
                  ? bounds.northeast.longitude
                  : point.longitude,
            ),
            southwest: LatLng(
              bounds.southwest.latitude < point.latitude
                  ? bounds.southwest.latitude
                  : point.latitude,
              bounds.southwest.longitude < point.longitude
                  ? bounds.southwest.longitude
                  : point.longitude,
            ),
          );
        }
      }

      // Animate the camera to fit the bounds with some padding
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
            bounds, 100), // Adjust the padding as needed
      );
    }
  }

  Future<void> _getDirections() async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${SLiITMalabe.latitude},${SLiITMalabe.longitude}&destination=${startingCoordinates.latitude},${startingCoordinates.longitude}&key=';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        _createPolylines(data);
        // Extract distance and duration from the response
        setState(() {
          _distance = data['routes'][0]['legs'][0]['distance']['text'];
          _duration = data['routes'][0]['legs'][0]['duration']['text'];
        });
        _fitPolyLines(); // Adjust the camera view to fit the polyline
      } else {
        // Handle error from Google Directions API
        print('Error: ${data['status']}');
      }
    } else {
      // Handle HTTP error
      print('Failed to load directions');
    }
  }

  void _createPolylines(Map<String, dynamic> data) {
    // Decode the encoded polyline from the directions response
    String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
    List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          width: 5,
          color: Colors.blue,
        ),
      );
    });
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
        _showNotification(); // Trigger notification
        _showDistanceDialog(); // Show alert dialog
      }
      if (distance <= 0) {
        _showArrivalDialog(); // Trigger notification
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _focusOnSLiIT() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${SLiITMalabe.latitude},${SLiITMalabe.longitude}&destination=${startingCoordinates.latitude},${startingCoordinates.longitude}&travelmode=driving';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 85, 218,
              105), // Different background color for the arrival dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  color: Colors.green, size: 50), // Check icon for success
              SizedBox(height: 10), // Space between icon and text
              Text(
                'Success!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Padding for the content
            child: Text(
              'You have successfully arrived at the destination.',
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    startingLocation = ModalRoute.of(context)?.settings.arguments as String;

    startingCoordinates =
        locationCoordinates[startingLocation] ?? LatLng(6.9271, 79.8612);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 0.0), // Adjust this value if needed
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: startingCoordinates,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('startLocation'),
                  position: startingCoordinates,
                  infoWindow: InfoWindow(
                    title: 'Bus Stop',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: MarkerId('sliitLocation'),
                  position: SLiITMalabe,
                  infoWindow: InfoWindow(
                    title: 'SLiIT Malabe',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              },
              polylines: _polylines,
              mapType: MapType.normal,
            ),
          ),
          Positioned(
            bottom: 10, // Adjusted to leave space for the bottom nav bar
            left: 5, // Aligns the box to the left corner
            right: null, // Removes the right constraints
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
              ),
              elevation: 8, // Slightly higher elevation for shadow effect
              child: Container(
                width: 340, // Change this value to decrease the width
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3F51B5),
                      Color(0xFF2196F3)
                    ], // Gradient background
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                      15.0), // Same rounded corners as card
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      15.0), // Increased padding for a balanced look
                  child: Column(
                    children: [
                      if (_distance != null && _duration != null)
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.map,
                                    color: Colors.white), // Distance icon
                                SizedBox(width: 8),
                                Text(
                                  'Distance: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _distance!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Space between rows
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.white), // Time icon
                                SizedBox(width: 8),
                                Text(
                                  'Estimated Time: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _duration!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Text(
                          'Fetching directions...',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 35, // Position above the bottom navigation
            right: 80, // Adjust this value for horizontal alignment
            child: FloatingActionButton(
              onPressed: _focusOnSLiIT,
              child: Icon(Icons.play_arrow),
              backgroundColor: Color.fromARGB(255, 73, 159, 230),
            ),
          ),
          Positioned(
            bottom: 100, // Position above the bottom navigation
            right: 5, // Adjust this value for horizontal alignment
            child: FloatingActionButton(
              onPressed: _showDistanceDialog, // Call the new method
              child: Icon(Icons.stop),
              backgroundColor: Color.fromARGB(255, 73, 159, 230),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    spreadRadius: 0.5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
