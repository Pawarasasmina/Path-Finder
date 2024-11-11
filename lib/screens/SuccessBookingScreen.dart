import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/database_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared preferences
import '../widgets/custom_app_bar.dart';

class SuccessBookingScreen extends StatefulWidget {
  final String busName;
  final String startingLocation;
  final String endingLocation;
  final int seatCount;

  SuccessBookingScreen({
    required this.busName,
    required this.startingLocation,
    required this.endingLocation,
    required this.seatCount,
  });

  @override
  _SuccessBookingScreenState createState() => _SuccessBookingScreenState();
}

class _SuccessBookingScreenState extends State<SuccessBookingScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _currentIndex = 0; // Default index for home

  @override
  void initState() {
    super.initState();
    _initializeNotificationPlugin();
    // Insert the booking data into the database
    _insertBooking();
    _showNotification(); // Send notification when booking is confirmed
  }

  // Initialize the notification plugin
  void _initializeNotificationPlugin() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Method to show a notification and save it to shared preferences
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // You can customize this
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Booking Confirmed',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Booking Confirmed', // Notification title
      'Your booking for ${widget.busName} has been confirmed!', // Notification body
      platformChannelSpecifics,
      payload: 'booking-confirmed', // Optional: add payload if needed
    );

    // Save notification message and time to shared preferences
    await _saveNotificationToPreferences(
      'Your booking for ${widget.busName} has been confirmed!',
      DateTime.now().toString(), // Save the current timestamp
    );
  }

  // Method to save notification data to shared preferences
  Future<void> _saveNotificationToPreferences(
      String message, String timestamp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedNotifications =
        prefs.getStringList('notifications') ?? [];

    // Combine message and timestamp
    String notificationEntry = '$message - $timestamp';
    storedNotifications.add(notificationEntry); // Add new notification entry
    await prefs.setStringList(
        'notifications', storedNotifications); // Save back to preferences
  }

  // Method to insert booking data into the database
  void _insertBooking() async {
    Map<String, dynamic> booking = {
      'busName': widget.busName,
      'startingLocation': widget.startingLocation,
      'endingLocation': widget.endingLocation,
      'seatCount': widget.seatCount,
    };

    await DatabaseHelper().insertBooking(booking);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Color(0xFF011A33),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF379D9D),
                      size: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Bus: ${widget.busName}',
                        style: TextStyle(color: Colors.black)),
                    Text('From: ${widget.startingLocation}',
                        style: TextStyle(color: Colors.black)),
                    Text('To: ${widget.endingLocation}',
                        style: TextStyle(color: Colors.black)),
                    Text('Seats: ${widget.seatCount}',
                        style: TextStyle(color: Colors.black)),
                    SizedBox(height: 10),
                    Text(
                      'Please be on time at the bus stop to avoid inconvenience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'lib/assets/bus_halt.png', // Ensure this path is correct
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/mapModel',
                          arguments: widget.startingLocation,
                        );
                      },
                      child: Text(
                        'Navigate to Bus Stop',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 17, 3, 3),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF379D9D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "🎉 You have successfully booked your tickets! 🚌",
                          style: TextStyle(fontSize: 16),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/pathFinder');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        parentContext: context,
        currentIndex: _currentIndex, // Pass the current index
      ),
    );
  }
}
