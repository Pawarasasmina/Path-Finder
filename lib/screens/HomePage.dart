import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screens/page1.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart'; // Assuming your BottomNavBar is in widgets folder
import './display_id.dart'; // Import the DisplayIDPage
import './park_selection_screen.dart'; // Import the ParkSelection screen
import './path_finder_screen.dart'; // Import the PathFinderScreen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0; // Initialize the currentIndex for BottomNavBar

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF011A33),
              Color(0xFF000A14)
            ], // Dark blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              // Allow scrolling if the content is large
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildFeatureCards(),
                  SizedBox(
                      height: 30), // Adding space before the new animations
                  _buildAdditionalAnimations(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(
                parentContext: context,
                currentIndex: _currentIndex, // Pass the current index
              ),
            ),
            _buildActionButtons(context), // Add action buttons here
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Header Section with Animated Traffic Overview
  Widget _buildHeader() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('lib/assets/images/logo.png'),
          ),
        ],
      ),
    );
  }

  // Feature Cards for Traffic, Routes, Parking, Buses
  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureCard('Traffic', Icons.traffic, Colors.red,
              'lib/assets/animations/traffic_animation_2.json'),
          _buildFeatureCard('Routes', Icons.alt_route, Colors.green,
              'lib/assets/animations/routes_icon.json'),
          _buildFeatureCard('Parking', Icons.local_parking, Colors.orange,
              'lib/assets/animations/parking.json'),
          _buildFeatureCard('Buses', Icons.directions_bus, Colors.blue,
              'lib/assets/animations/bus_icon.json'),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color iconColor, String animationPath) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            print('$title card tapped');
            _showFeatureDialog(title, animationPath); // Tap interaction
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Lottie.asset(animationPath,
                repeat: true), // Lottie for icon animations
          ),
        ),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  void _showFeatureDialog(String title, String animationPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Lottie.asset(animationPath, height: 150),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdditionalAnimations() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('lib/assets/animations/routes_icon.json',
                    height: 100),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Smart Route Suggestions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Find the best route to your ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      ' destination.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      bottom: 100, // Adjust this to position the buttons above the bottom nav
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Parking Slot Button
          Expanded(
            child: Container(
              height: 70, // Slightly taller for a bolder look
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF379D9D), Color(0xFF4ECDC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParkSelection(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.view_list,
                  color: Colors.white,
                  size: 28, // Increased icon size
                ),
                label: Text(
                  'Parking \nSlots',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Increased font size for readability
                    fontWeight: FontWeight.bold, // Bold font
                  ),
                  textAlign: TextAlign.center, // Centered text alignment
                ),
              ),
            ),
          ),
          SizedBox(width: 10), // Space between buttons

          // Middle Floating Button
          FloatingActionButton(
            onPressed: () {
              _navigateToNextPage(context);
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.navigation, size: 30), // Larger icon size
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(50), // Explicit circular shape
            ),
            elevation: 8, // Slightly higher elevation for effect
          ),
          SizedBox(width: 10), // Space between buttons

          // Parking ID Button
          Expanded(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF379D9D), Color(0xFF4ECDC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PathFinderScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 28, // Increased icon size
                ),
                label: Text(
                  'Buses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Increased font size for readability
                    fontWeight: FontWeight.bold, // Bold font
                  ),
                  textAlign: TextAlign.center, // Centered text alignment
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNextPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => Page1(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
