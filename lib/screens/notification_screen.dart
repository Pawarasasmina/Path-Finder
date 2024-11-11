import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the BottomNavBar widget
import '../widgets/custom_app_bar.dart'; // Import the CustomAppBar widget

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> notifications = []; // Keep notifications as a simple list

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedNotifications = prefs.getStringList('notifications');

    setState(() {
      notifications =
          storedNotifications ?? []; // Initialize with an empty list if null
    });
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 2; // Set the index for the Notifications page

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF011A33), Color(0xFF000A14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications available.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationCard(
                          notification: notifications[index]);
                    },
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              parentContext: context,
              currentIndex: _currentIndex, // Pass the current index
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // Change to a lighter color
        borderRadius: BorderRadius.circular(15), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Darker shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(
            Icons.message, // Changed to message icon
            color: Color(0xFF4ECDC4), // Set a contrasting color
            size: 30,
          ),
          const SizedBox(width: 12), // Space between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification,
                  style: const TextStyle(
                    fontFamily: 'Sanchez',
                    fontSize: 16,
                    color: Colors.black87,
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
