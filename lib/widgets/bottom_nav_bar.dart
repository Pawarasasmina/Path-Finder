import 'package:flutter/material.dart';
import '../screens/profile.dart'; // Import your ProfilePage
import '../screens/show_booking_page.dart'; // Import your ShowBookingsPage
import '../screens/notification_screen.dart'; // Import your NotificationScreen
import '../screens/HomePage.dart';

class BottomNavBar extends StatelessWidget {
  final BuildContext parentContext; // Add a parameter to accept the context
  final int currentIndex; // Add a parameter for the current index

  const BottomNavBar({
    Key? key,
    required this.parentContext,
    required this.currentIndex, // Accept current index
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1C3D3F),
            Color(0xFF0D7070),
          ], // Define the gradient colors
          begin: Alignment.topCenter, // Starting point of the gradient
          end: Alignment.bottomCenter, // Ending point of the gradient
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ), // Adjust curvature here
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 2.0), // Changes position of shadow
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor:
            Colors.transparent, // Keep background transparent for curved effect
        selectedItemColor: Colors.transparent, // Temporarily hide default color
        unselectedItemColor: const Color(0xFFFFFFFF),
        showSelectedLabels: false, // Hide selected item labels
        showUnselectedLabels: false, // Hide unselected item labels
        type:
            BottomNavigationBarType.fixed, // Important for consistent icon size
        currentIndex: currentIndex, // Set the current index
        items: [
          BottomNavigationBarItem(
            icon: _buildIconWithGradient(Icons.home_outlined,
                currentIndex == 0), // Apply gradient for selection
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithGradient(Icons.directions_bus_filled_outlined,
                currentIndex == 1), // Apply gradient for selection
            label: 'Parking',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithGradient(Icons.notifications_outlined,
                currentIndex == 2), // Apply gradient for selection
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithGradient(Icons.person_outline,
                currentIndex == 3), // Apply gradient for selection
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home Page (you'll need to implement this)
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );

              break;
            case 1:
              // Navigate to Show Bookings Page
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => ShowBookingsPage(),
                ),
              );
              break;
            case 2:
              // Navigate to Alerts Page
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
              break;
            case 3:
              // Navigate to Profile Page
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildIconWithGradient(IconData icon, bool isSelected) {
    if (isSelected) {
      return ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Color(0xFF379D9D), // Start color
              Color(0xFF4ECDC4), // End color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        child: Icon(icon,
            size: 30, color: Colors.white), // Apply gradient to selected icon
      );
    } else {
      return Icon(icon,
          size: 30, color: Colors.white); // Default color for unselected icons
    }
  }
}
