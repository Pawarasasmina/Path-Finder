import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared preferences
import '../screens/park_selection_screen.dart';
import '../screens/path_finder_screen.dart';
import '../screens/parking_id.dart';

class PopupForm2 extends StatefulWidget {
  const PopupForm2({Key? key}) : super(key: key);

  @override
  _PopupForm2State createState() => _PopupForm2State();
}

class _PopupForm2State extends State<PopupForm2> {
  bool _isAutoExtend = false;
  bool _isInitialWait = true;
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isReserved = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotificationPlugin();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isInitialWait = false;
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate checking slots
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reserveSlot() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate reservation
    setState(() {
      _isProcessing = false;
      _isReserved = true;
    });
    await _showNotification(); // Show notification when reservation is confirmed
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

  // Show notification method and save it to shared preferences
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Reservation Confirmed',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Reservation Confirmed',
      'Your parking slot has been reserved successfully!',
      platformChannelSpecifics,
    );

    // Save notification message and time to shared preferences
    await _saveNotificationToPreferences(
      'Your parking slot has been reserved successfully!',
      DateTime.now().toString(), // Save the current timestamp
    );
  }

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

  // Method to show an alert dialog for auto-extend activation
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Auto Extend Activated',
            style: TextStyle(
              fontFamily: 'Sanchez',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Auto Extend has been enabled.\nYour reservation will be automatically extended if necessary.',
            style: TextStyle(
              fontFamily: 'Sanchez',
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE6E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isInitialWait) ...[
              // UI code remains unchanged
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please Wait ...',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 18,
                  color: Color(0xFF000000),
                ),
              ),
            ] else if (_isLoading) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Checking slots availability...',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 18,
                  color: Color(0xFF000000),
                ),
              ),
            ] else if (_isProcessing) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Processing reservation...',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 18,
                  color: Color(0xFF000000),
                ),
              ),
            ] else if (_isReserved) ...[
              const SizedBox(height: 10),
              Image.asset(
                'lib/assets/animations/success_animation.gif',
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10),
              const Text(
                'Parking slot reserved successfully!',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 24,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ParkingIDPage(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: const Color(0xFFFAFAFA),
                ),
                child: const Text('Generate Parking ID'),
              ),
            ] else ...[
              // UI code remains unchanged
              Row(
                children: [
                  const Icon(
                    Icons.notification_important,
                    color: Color(0xFF000000),
                    size: 28,
                  ),
                  const SizedBox(width: 72),
                  const Text(
                    'Alert',
                    style: TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 32,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF1C3D3F), thickness: 2),
              const SizedBox(height: 10),
              const Text(
                'Sorry to inform\nthat there are no\navailable slots\nright now!',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 24,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Auto Extend',
                    style: TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 28,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isAutoExtend,
                    onChanged: (bool value) {
                      setState(() {
                        _isAutoExtend = value;
                      });
                      if (value) {
                        _showAlertDialog(context); // Show alert on toggle
                      }
                    },
                    activeColor: const Color(0xFF4ECDC4),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _reserveSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: const Color(0xFFFAFAFA),
                ),
                child: const Text('Reserve'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
