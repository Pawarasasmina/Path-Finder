import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'last.dart'; // Import page3 if you have it
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class route extends StatefulWidget {
  final LatLng startLocation; // Starting location from Page1
  final LatLng destination; // Destination from Page1

  const route({
    Key? key,
    required this.startLocation,
    required this.destination,
  }) : super(key: key); // Include super to handle the key

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<route> {
  int _currentIndex = 1; // Track the current index of the BottomNavBar
  @override
  void initState() {
    super.initState();

    // Add a delay before auto-navigating to Page3
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to Page3 after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => last(
              startLocation: widget.startLocation,
              destination: widget.destination),
        ),
      );
    });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(), // Add a loading indicator
            const SizedBox(height: 20),
            const Text(
              'Checking Paths...',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        parentContext: context,
        currentIndex: _currentIndex, // Pass the current index
      ),
    );
  }
}
