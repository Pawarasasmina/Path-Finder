import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/parking_area_grid.dart';
import '../widgets/info_text.dart';
import '../widgets/check_availability_button.dart';
import '../widgets/Parkinginfo.dart';
import '../widgets/popup_form_2.dart'; // Import the new popup form

class Park02View extends StatelessWidget {
  const Park02View({Key? key}) : super(key: key);

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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Parking Area 02',
                    style: TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ParkingAreaGrid(), // Adjust the item count as needed
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
                    openingHours: '9 a.m - 8 p.m',
                    chargingMethod: 'Rs. 350 per Hour',
                    evChargerSlots: 'Available: 2',
                  ),
                  const InfoText(
                    text:
                        'Our parking area offers easy access to popular attractions with 24/7 security. Book your slot in advance for hassle-free parking!',
                    rating: 4.1,
                  ),
                  const SizedBox(height: 20),
                  CheckAvailabilityButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const PopupForm2(),
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Add space at the bottom
                ],
              ),
            ),
          ),
          // BottomNavigationBar overlapping the body
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
