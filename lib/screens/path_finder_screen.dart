import 'package:flutter/material.dart';
import '../widgets/bus_card.dart';
import '../widgets/location_input.dart';
import '../widgets/time_selector.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the BottomNavBar
import '../widgets/custom_app_bar.dart';

class PathFinderScreen extends StatefulWidget {
  @override
  _PathFinderScreenState createState() => _PathFinderScreenState();
}

class _PathFinderScreenState extends State<PathFinderScreen> {
  int selectedTimeOption = 1; // Track the time selection option
  int _currentIndex = 1; // Track the current index of the bottom nav
  String startingLocation = ''; // Track starting location input
  String endingLocation = ''; // Track ending location input

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic here for different tabs
  }

  // Example list of bus details
  final List<Map<String, dynamic>> busDetails = [
    {
      'busName': 'Sunway Travels',
      'busType': 'Semi-luxury non-AC bus',
      'seatsAvailable': 54,
      'speed': 'Express',
      'startPoint': 'Kothalawala',
      'endPoint': 'Colombo',
    },
    {
      'busName': 'City Link',
      'busType': 'Luxury AC bus',
      'seatsAvailable': 30,
      'speed': 'Regular',
      'startPoint': 'Pettah',
      'endPoint': 'Galle',
    },
    {
      'busName': 'Rapid Transit',
      'busType': 'Non-AC bus',
      'seatsAvailable': 40,
      'speed': 'Express',
      'startPoint': 'Fort',
      'endPoint': 'Kandy',
    },
    {
      'busName': 'Comfort Rides',
      'busType': 'Luxury Non-AC bus',
      'seatsAvailable': 50,
      'speed': 'Regular',
      'startPoint': 'Mount Lavinia',
      'endPoint': 'Nugegoda',
    },
  ];

  List<Map<String, dynamic>> filteredBusDetails = [];

  @override
  void initState() {
    super.initState();
    // Initially show all bus details
    filteredBusDetails = busDetails;
  }

  void _searchBuses() {
    FocusScope.of(context).unfocus(); // Dismiss the keyboard

    setState(() {
      // Filter buses based on the starting and ending locations
      filteredBusDetails = busDetails.where((bus) {
        final isStartingLocationValid = bus['startPoint']
            .toLowerCase()
            .contains(startingLocation.toLowerCase());
        final isEndingLocationValid = bus['endPoint']
            .toLowerCase()
            .contains(endingLocation.toLowerCase());

        return isStartingLocationValid && isEndingLocationValid; // Match both
      }).toList();
    });
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
      body: Stack(
        children: [
          // Body content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF011A33), // Top color
                  Color(0xE4011830), // Bottom color
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // White box containing location input, time selector, and search button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Input Fields (Using LocationInput Widget)
                      LocationInput(
                        onStartingLocationChanged: (value) {
                          setState(() {
                            startingLocation =
                                value; // Update starting location
                          });
                        },
                        onEndingLocationChanged: (value) {
                          setState(() {
                            endingLocation = value; // Update ending location
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Time Selection (Using TimeSelector Widget)
                      TimeSelector(
                        selectedTimeOption: selectedTimeOption,
                        onTimeSelected: (value) {
                          setState(() {
                            selectedTimeOption = value;
                          });
                        },
                      ),

                      SizedBox(height: 16),

                      // Search Button
                      ElevatedButton(
                        onPressed: _searchBuses, // Call the search function
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors
                                  .white, // Set the color of the search icon
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: Colors
                                    .white, // Set the color of the search text
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(
                              0xFF265656), // Set the background color of the button
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                          // You can set the foreground color here if you want
                          foregroundColor: Colors
                              .teal, // Optional: Set the default text color for the button
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Add a white horizontal line
                Divider(
                  color: Colors.white, // Color of the line
                  thickness: 2, // Thickness of the line
                  height: 20, // Height of the space around the line
                ),

                SizedBox(height: 10),

                // Available Buses List (Using BusCard Widget)
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredBusDetails.length,
                    itemBuilder: (ctx, index) {
                      final bus = filteredBusDetails[index];
                      return BusCard(
                        busName: bus['busName'],
                        busType: bus['busType'],
                        seatsAvailable: bus['seatsAvailable'],
                        speed: bus['speed'],
                        startPoint: bus['startPoint'],
                        endPoint: bus['endPoint'],
                        startingLocation:
                            startingLocation, // Pass the starting location
                        endingLocation:
                            endingLocation, // Pass the ending location
                      );
                    },
                  ),
                ),
                SizedBox(height: 40),
              ],
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
