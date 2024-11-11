import 'package:flutter/material.dart';
import '../utils/database_helper.dart'; // Import your database helper
import '../widgets/custom_app_bar.dart'; // Import the custom app bar
import '../widgets/bottom_nav_bar.dart'; // Import the BottomNavBar
import 'package:shared_preferences/shared_preferences.dart'; // Import Shared Preferences
import '../screens/login_page.dart'; // Import the LoginPage for navigation
import '../widgets/custom_logout_button.dart';
import '../screens/display_id.dart'; // Import the DisplayIDPage for QR code display

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData; // To store fetched user data
  String? userEmail; // To store email fetched from Shared Preferences
  int _currentIndex = 3; // Initialize the selected index to Profile tab

  @override
  void initState() {
    super.initState();
    _fetchEmailFromPreferences(); // Fetch email from Shared Preferences
  }

  Future<void> _fetchEmailFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email'); // Get email from Shared Preferences

    if (userEmail != null) {
      _fetchUserData(userEmail!); // Fetch user data with the email
    }
  }

  Future<void> _fetchUserData(String email) async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Fetch user data by email
    final user = await dbHelper.getUserByEmail(email);

    setState(() {
      userData = user; // Store the fetched user data
    });
  }

  Future<void> _logout() async {
    // Clear email and QR code from Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Remove email
    await prefs.remove('qrData'); // Remove QR code data

    // Navigate back to the Login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );

    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully logged out!')),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
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
                const Row(
                  children: [
                    Icon(
                      Icons.logout, // Logout icon
                      color: Color(0xFF000000),
                      size: 28,
                    ),
                    SizedBox(width: 10), // Space between icon and text
                    Text(
                      'Logout',
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
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontFamily: 'Sanchez',
                    fontSize: 24,
                    color: Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFF6B6B), // Button color for No
                        foregroundColor: const Color(0xFFFAFAFA), // Text color
                      ),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _logout(); // Perform logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF4ECDC4), // Button color for Yes
                        foregroundColor: const Color(0xFFFAFAFA), // Text color
                      ),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile', // Set the title for the app bar
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          // Body content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF011A33), Color(0xFF000A14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 60, // Increased size
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 60, // Increased icon size
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: userData == null
                          ? const CircularProgressIndicator()
                          : Text(
                              userData!['name'],
                              style: const TextStyle(
                                fontSize: 32, // Increased font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white70),
                    const SizedBox(height: 10),
                    if (userData != null) ...[
                      _buildProfileInfo(
                          Icons.email, 'Email', userData!['email']),
                      _buildProfileInfo(Icons.phone, 'Contact Number',
                          userData!['contactNumber']),
                      _buildProfileInfo(Icons.directions_car, 'Vehicle Number',
                          userData!['vehicleNumber']),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: CustomLogoutButton(
                        onPressed: _confirmLogout, // Show confirmation dialog
                      ),
                    ),
                    const SizedBox(height: 140), // Add space at the bottom
                  ],
                ),
              ),
            ),
          ),
          // BottomNavigationBar positioned at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              parentContext: context,
              currentIndex: _currentIndex, // Pass the current index
            ),
          ),
          // FloatingActionButton positioned at the top left
          Positioned(
            top: 16, // Adjust top position as needed
            left: 16, // Adjust left position as needed
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayIDPage()),
                );
              },
              backgroundColor: const Color(0xFF4ECDC4), // Set the button color
              child: const Icon(Icons.qr_code, size: 30), // QR code icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.white12,
        elevation: 6, // Adjusted elevation
        shadowColor: Colors.black26, // Shadow color for better effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFF4ECDC4), // Color to match your theme
          ),
          title: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
