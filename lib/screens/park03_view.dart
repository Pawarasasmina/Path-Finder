import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/parking_area_grid.dart';
import '../widgets/info_text.dart';
import '../widgets/check_availability_button.dart';
import '../widgets/ParkingInfo.dart';
import '../widgets/popup_form.dart'; // Import the popup form

class Park03View extends StatelessWidget {
  const Park03View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1; // Set to 1 for the Parking page
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Parking Area 03',
                    style: TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ParkingAreaGrid(),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: const Text(
                      '- Parking Area Map -',
                      style: TextStyle(
                        fontFamily: 'Sanchez',
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const ParkingInfo(
                    openingHours: '10 a.m - 10 p.m',
                    chargingMethod: 'Rs. 450 per Hour',
                    evChargerSlots: '4 Available',
                  ),
                  const InfoText(
                    text:
                        'Our parking slots provide convenient, secure access near key locations with real-time availability updates and competitive pricing. Reserve ahead to save time and enjoy stress-free parking.',
                    rating: 4.5,
                  ),
                  const SizedBox(height: 20),
                  CheckAvailabilityButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const PopupForm(), // Show the popup form
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Add space at the bottom
                ],
              ),
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
