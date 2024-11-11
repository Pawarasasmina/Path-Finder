import 'package:flutter/material.dart';
import '../screens/park_selection_screen.dart'; // Import your park selection screen

class PopupForm extends StatefulWidget {
  const PopupForm({Key? key}) : super(key: key);

  @override
  _PopupFormState createState() => _PopupFormState();
}

class _PopupFormState extends State<PopupForm> {
  bool _isInitialWait = true; // State for initial wait
  bool _isLoading = false; // State for loading spinner

  @override
  void initState() {
    super.initState();
    _loadData(); // Start loading data
  }

  Future<void> _loadData() async {
    // First wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isInitialWait = false; // Switch to loading state
      _isLoading = true; // Show loading spinner
    });

    // Simulate checking slot availability
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time
    setState(() {
      _isLoading = false; // Hide loading spinner
    });
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ), // Loading spinner
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
              ), // Loading spinner
              const SizedBox(height: 10),
              const Text(
                'Checking slots availability...',
                style: TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 18,
                  color: Color(0xFF000000),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(
                    Icons.notification_important, // Notification icon
                    color: Color(0xFF000000), // Icon color
                    size: 28, // Size of the icon
                  ),
                  const SizedBox(width: 72), // Space between icon and text
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
              const Divider(
                  color: Color(0xFF1C3D3F), thickness: 2), // Horizontal line
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
              const Divider(
                  color: Color(0xFF1C3D3F), thickness: 2), // Horizontal line
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        const ParkSelection(), // Navigate to park selection screen
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B), // Button color
                  foregroundColor: const Color(0xFFFAFAFA), // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
