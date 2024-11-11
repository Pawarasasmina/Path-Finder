import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/parking_card.dart';
import '../widgets/filter_dropdown.dart';
import '../screens/park01_view.dart';
import '../screens/park02_view.dart';
import '../screens/park03_view.dart'; // Import the new view
import '../screens/park04_view.dart'; // Import the new view

class ParkSelection extends StatefulWidget {
  const ParkSelection({Key? key}) : super(key: key);

  @override
  _ParkSelectionState createState() => _ParkSelectionState();
}

class _ParkSelectionState extends State<ParkSelection> {
  String? selectedFilter;
  List<ParkingArea> parkingAreas = [
    ParkingArea('Parking Area 01', '500.00', 4.8),
    ParkingArea('Parking Area 02', '350.00', 4.1),
    ParkingArea('Parking Area 03', '450.00', 4.5),
    ParkingArea('Parking Area 04', '400.00', 3.5),
  ];

  // Define the current index for the BottomNavBar
  int _currentIndex = 1; // Set to 1 for the Parking tab

  @override
  Widget build(BuildContext context) {
    // Filter parking areas based on selected filter
    List<ParkingArea> filteredParkingAreas = List.from(parkingAreas);

    if (selectedFilter == 'Price') {
      filteredParkingAreas.sort(
          (a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
    } else if (selectedFilter == 'Rating') {
      filteredParkingAreas.sort((a, b) => b.rating.compareTo(a.rating));
    }

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilterDropdown(
                    onFilterChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue; // Update selected filter
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredParkingAreas.length,
                    padding:
                        const EdgeInsets.only(bottom: 80.0), // Adjust as needed
                    itemBuilder: (context, index) {
                      final area = filteredParkingAreas[index];
                      return ParkingCard(
                        areaName: area.name,
                        price: area.price,
                        rating: area.rating,
                        onViewButtonPressed: () {
                          // Add navigation logic based on the selected area
                          if (area.name == 'Parking Area 01') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Park01View(),
                              ),
                            );
                          } else if (area.name == 'Parking Area 02') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Park02View(),
                              ),
                            );
                          } else if (area.name == 'Parking Area 03') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Park03View(),
                              ),
                            );
                          } else if (area.name == 'Parking Area 04') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Park04View(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensure it wraps around the bottom content
              children: [
                SizedBox(height: 16), // Space before the BottomNavBar
                BottomNavBar(
                  parentContext: context,
                  currentIndex: _currentIndex, // Pass the current index
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingArea {
  final String name;
  final String price;
  final double rating;

  ParkingArea(this.name, this.price, this.rating);
}
