import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './LoadingScreen.dart';
import './SuccessBookingScreen.dart';
import '../services/database_helper.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the BottomNavBar
import '../widgets/custom_app_bar.dart';

class ShowBookingsPage extends StatefulWidget {
  @override
  _ShowBookingsPageState createState() => _ShowBookingsPageState();
}

class _ShowBookingsPageState extends State<ShowBookingsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _bookings = [];
  int _currentIndex = 1; // Track the current index of the bottom nav

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // Fetch bookings when the page loads
  }

  Future<void> _fetchBookings() async {
    final bookings = await dbHelper.fetchBookings();
    setState(() {
      _bookings = bookings;
    });
  }

  void _goNow(BuildContext context, Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingScreen()),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessBookingScreen(
            busName: booking['busName'],
            startingLocation: booking['startingLocation'],
            endingLocation: booking['endingLocation'],
            seatCount: booking['seats'],
          ),
        ),
      );
    });
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic here for different tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Saved Bookings',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF011A33),
                  Color(0xE4011830),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _bookings.isEmpty
                ? Center(
                    child: Text(
                      'No saved bookings available.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];

                      DateTime scheduledDate;
                      DateTime scheduledTime;

                      if (booking['date'] != null &&
                          booking['time'] != null &&
                          booking['date'] != "now" &&
                          booking['time'] != "now") {
                        try {
                          scheduledDate =
                              DateFormat('dd/MM/yyyy').parse(booking['date']);
                          scheduledTime =
                              DateFormat.jm().parse(booking['time']);

                          DateTime scheduledDateTime = DateTime(
                            scheduledDate.year,
                            scheduledDate.month,
                            scheduledDate.day,
                            scheduledTime.hour,
                            scheduledTime.minute,
                          );

                          DateTime currentTime = DateTime.now();

                          bool isDepartingSoon =
                              scheduledDateTime.isAfter(currentTime) &&
                                  scheduledDateTime.isBefore(
                                      currentTime.add(Duration(minutes: 15)));

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              title: Text(
                                'Bus from ${booking['startingLocation']} to ${booking['endingLocation']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF011A33),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Seats: ${booking['seats']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'Schedule: ${booking['scheduleType']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'Date: ${booking['date']} | Time: ${booking['time']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              leading: Icon(
                                Icons.event_seat,
                                size: 40,
                                color: Color(0xFF379D9D),
                              ),
                              trailing: isDepartingSoon
                                  ? ElevatedButton(
                                      onPressed: () => _goNow(context, booking),
                                      child: Text('Go Now'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF379D9D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          );
                        } catch (e) {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
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
