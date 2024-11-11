import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './SuccessBookingScreen.dart'; // Import the SuccessBookingScreen
import './LoadingScreen.dart'; // Import the LoadingScreen

class ScheduledBookingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> scheduledBookings;

  ScheduledBookingsPage({required this.scheduledBookings});

  // Function to navigate to LoadingScreen, then to SuccessBookingScreen
  void _goNow(BuildContext context, Map<String, dynamic> booking) {
    // Navigate to LoadingScreen first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingScreen()),
    );

    // Simulate a delay for loading, then navigate to SuccessBookingScreen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessBookingScreen(
            busName: booking['busName'],
            startingLocation: booking['startingLocation'],
            endingLocation: booking['endingLocation'],
            seatCount: booking[
                'seatCount'], // Ensure you have this field in your booking
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduled Bookings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w200,
            color: Color(0xFF379D9D),
            fontFamily: 'Alfa Slab One',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF011A33),
      ),
      body: Container(
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
        child: ListView.builder(
          itemCount: scheduledBookings.length,
          itemBuilder: (context, index) {
            final booking = scheduledBookings[index];

            // Check if the date and time are valid and not "now"
            if (booking['date'] != null &&
                booking['time'] != null &&
                booking['date'] != "now" &&
                booking['time'] != "now") {
              // Parse the scheduled date and time
              DateTime scheduledDate = DateFormat('dd/MM/yyyy').parse(
                  booking['date']); // Updated to match the correct date format
              DateTime scheduledTime = DateFormat.jm().parse(booking['time']);

              // Combine date and time into a single DateTime object
              DateTime scheduledDateTime = DateTime(
                scheduledDate.year,
                scheduledDate.month,
                scheduledDate.day,
                scheduledTime.hour,
                scheduledTime.minute,
              );

              DateTime currentTime = DateTime.now();

              // Check if the bus is departing today and within the next 15 minutes
              bool isDepartingSoon = scheduledDateTime.isAfter(currentTime) &&
                  scheduledDateTime
                      .isBefore(currentTime.add(Duration(minutes: 15)));

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(
                    booking['busName'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011A33),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${booking['startingLocation']} To: ${booking['endingLocation']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date: ${booking['date']} Time: ${booking['time']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  leading:
                      Icon(Icons.bus_alert, size: 40, color: Color(0xFF379D9D)),
                  // Leading icon
                  trailing: isDepartingSoon
                      ? ElevatedButton(
                          onPressed: () =>
                              _goNow(context, booking), // Go Now button
                          child: Text('Go Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF379D9D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        )
                      : SizedBox.shrink(), // Hide button if not departing soon
                ),
              );
            } else {
              return Container(); // Return an empty container if the booking is not valid
            }
          },
        ),
      ),
    );
  }
}
