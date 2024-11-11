import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/database_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/path_finder_screen.dart';

class ParkingIDPage extends StatefulWidget {
  const ParkingIDPage({Key? key}) : super(key: key);

  @override
  _ParkingIDPageState createState() => _ParkingIDPageState();
}

class _ParkingIDPageState extends State<ParkingIDPage> {
  Map<String, dynamic>? userData;
  String? parkingInfo;
  String? userEmail;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchEmailFromPreferences();
  }

  Future<void> _fetchEmailFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');

    if (userEmail != null) {
      _fetchUserData(userEmail!);
    }
  }

  Future<void> _fetchUserData(String email) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final user = await dbHelper.getUserByEmail(email);

    setState(() {
      userData = user;
      parkingInfo = _getParkingInfo(); // Fetch parking info
    });
  }

  String? _getParkingInfo() {
    return "Parking Area 02, Rate: Rs. 350 per Hour";
  }

  Future<void> _saveQrData(String qrData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('qrData', qrData);
  }

  @override
  Widget build(BuildContext context) {
    String qrData = userData != null && parkingInfo != null
        ? "Name:${userData!['name']},Email:${userData!['email']},ParkingInfo:$parkingInfo"
        : "Generating QR...";

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Parking ID',
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Your Parking ID:',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Container for QR code
                    if (qrData != "Generating QR...")
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: CustomPaint(
                          size: const Size(250, 250),
                          painter: QrPainter(
                            data: qrData,
                            version: QrVersions.auto,
                            gapless: false,
                            color: const Color(0xFF000000),
                            emptyColor: const Color(0xFFFFFFFF),
                          ),
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                    const SizedBox(height: 60),

                    // Proceed to Bus Seat Booking Button
                    GestureDetector(
                      onTap: () async {
                        await _saveQrData(qrData);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PathFinderScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF379D9D),
                              Color(0xFF4ECDC4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Proceed to Bus Seat Booking',
                          style: TextStyle(
                            fontFamily: 'Sanchez',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 180),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              parentContext: context,
              currentIndex: _currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}
