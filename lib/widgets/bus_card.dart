import 'package:flutter/material.dart';
import '../screens/booking_page.dart'; // Import the BookingPage

class BusCard extends StatelessWidget {
  final String busName;
  final String busType;
  final int seatsAvailable;
  final String speed;
  final String startPoint;
  final String? endPoint; // Make endPoint nullable
  final String startingLocation; // New property for starting location
  final String endingLocation; // New property for ending location

  BusCard({
    required this.busName,
    required this.busType,
    required this.seatsAvailable,
    required this.speed,
    required this.startPoint,
    this.endPoint, // Make endPoint optional
    required this.startingLocation, // Initialize startingLocation
    required this.endingLocation, // Initialize endingLocation
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
      child: Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/assets/busimage.jpeg',
                  width: 140,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16), // Space between image and text
              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      busName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800], // Change the color
                      ),
                    ),
                    SizedBox(height: 1),
                    Divider(
                      color: Colors.grey[800], // Color of the line
                      thickness: 1.5, // Thickness of the line
                    ), // Horizontal line under bus name
                    SizedBox(height: 1),
                    Text(
                      busType,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Using a Column to display seats and speed in separate rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_seat,
                                    size: 16, color: Colors.grey[700]),
                                SizedBox(width: 4),
                                Text('Seats: $seatsAvailable'),
                              ],
                            ),
                            SizedBox(
                                height: 4), // Space between seats and speed
                            Row(
                              children: [
                                Icon(Icons.speed,
                                    size: 16, color: Colors.grey[700]),
                                SizedBox(width: 4),
                                Text('Speed: $speed'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Add space before the starting point
                    // Start point displayed under the image
                    Text('Start: $startPoint',
                        style: TextStyle(color: Colors.black)),
                    SizedBox(height: 4), // Add some spacing
                    Text('End: ${endPoint ?? "N/A"}',
                        style: TextStyle(
                            color: Colors.black)), // Display end point
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the booking page with bus details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingPage(
                                busName: busName,
                                busType: busType,
                                seatsAvailable: seatsAvailable,
                                speed: speed,
                                startPoint: startPoint,
                                endPoint: endPoint,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.bookmark_add, size: 20),
                        label: Text('Book Now'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          backgroundColor: Color.fromARGB(255, 38, 153, 143),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
