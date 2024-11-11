import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../widgets/bottom_nav_bar.dart';
import './ScheduledBookingsPage.dart'; // Import the new page
import './LoadingScreen.dart'; // Adjust the path according to your project structure
import './SuccessBookingScreen.dart'; // Adjust the path according to your project structure
import '../services/database_helper.dart';

class BookingPage extends StatefulWidget {
  final String busName; // Dynamically passed bus name
  final String busType; // Dynamically passed bus type
  final int seatsAvailable; // Dynamically passed available seats
  final String speed; // Dynamically passed bus speed
  final String startPoint; // Dynamically passed starting point
  final String? endPoint; // Dynamically passed ending point

  BookingPage({
    required this.busName,
    required this.busType,
    required this.seatsAvailable,
    required this.speed,
    required this.startPoint,
    this.endPoint,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> _scheduledBookings = [];

  String? _startingLocation;
  String? _endingLocation;
  int _seatCount = 1;
  bool _isNow = true; // Set to true for default "Now" option
  DateTime? _selectedDate;
  String? _selectedTime; // Changed to String for dropdown
  int _currentIndex = 1; // Track the current index of the bottom nav

  final dbHelper = DatabaseHelper(); // Initialize the database helper

  List<String> _timeOptions = [
    '02:40 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '11:35 PM',
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic here for different tabs
  }

  @override
  void initState() {
    super.initState();
    _startingLocation = widget.startPoint; // Set initial starting location
    _endingLocation = widget.endPoint; // Set initial ending location
  }

  // For the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Booking"),
          content: Text("Do you want to confirm this booking?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog

                // Insert booking data to SQLite
                await _saveBookingToDatabase();

                // Pass data to the next page
                _handleBooking();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBookingToDatabase() async {
    Map<String, dynamic> bookingData = {
      'startingLocation': _startingLocation,
      'endingLocation': _endingLocation,
      'seats': _seatCount,
      'scheduleType': _isNow ? 'Now' : 'Scheduled',
      'date': _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : null,
      'time': _selectedTime,
    };

    await dbHelper.insertBooking(bookingData);
    print("Booking saved to database.");
  }

  void _handleBooking() {
    final booking = {
      'busName': widget.busName,
      'startingLocation': _startingLocation,
      'endingLocation': _endingLocation,
      'seatCount': _seatCount,
      'date': _isNow
          ? 'Now'
          : (_selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
              : 'Not Selected'),
      'time': _isNow
          ? 'Now'
          : (_selectedTime != null ? _selectedTime : 'Not Selected'),
    };

    // Add the booking to the scheduled bookings list
    _scheduledBookings.add(booking);

    if (!_isNow) {
      // Navigate to the ScheduledBookingsPage if not booking "Now"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScheduledBookingsPage(scheduledBookings: _scheduledBookings),
        ),
      );
    } else {
      // Navigate to the LoadingScreen for "Now" bookings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );

      // Simulate a delay for loading
      Future.delayed(Duration(seconds: 2), () {
        // Navigate to the SuccessBookingScreen with passed parameters
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessBookingScreen(
              busName: booking['busName'] as String, // Cast to String
              startingLocation:
                  booking['startingLocation'] as String, // Cast to String
              endingLocation:
                  booking['endingLocation'] as String, // Cast to String
              seatCount: booking['seatCount'] as int, // Cast to int
            ),
          ),
        );
      });
    }

    print(
        "Booking confirmed for $_seatCount seats from $_startingLocation to $_endingLocation");
    // Add any additional logic needed for booking confirmation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Path Finder',
          style: TextStyle(
            fontFamily: 'Alfa Slab One', // Custom font
            fontSize: 25,
            color: Color(0xFF379D9D),
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF011A33),
                  Color.fromARGB(227, 0, 15, 29),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              bottom: kBottomNavigationBarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'lib/assets/busimage.jpeg',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.busName,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.tealAccent,
                          ),
                        ),
                        Text(
                          widget.busType,
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text("Seats Available: ${widget.seatsAvailable}",
                            style: TextStyle(color: Colors.white)),
                        Text("Speed: ${widget.speed}",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("Starting Location:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                _buildTextInput(_startingLocation!, (value) {
                  setState(() {
                    _startingLocation = value;
                  });
                }),
                SizedBox(height: 20),
                Text("Ending Location:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                _buildTextInput(_endingLocation!, (value) {
                  setState(() {
                    _endingLocation = value;
                  });
                }),
                SizedBox(height: 20),
                Text("No. of Seats:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.white),
                      onPressed: _seatCount > 1
                          ? () {
                              setState(() {
                                _seatCount--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_seatCount',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _seatCount++;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("Schedule:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isNow,
                      onChanged: (value) {
                        setState(() {
                          _isNow = true; // For "Now"
                          _selectedDate = null; // Reset date
                          _selectedTime = null; // Reset time
                        });
                      },
                    ),
                    Text('Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        )),
                    Radio<bool>(
                      value: false,
                      groupValue: _isNow,
                      onChanged: (value) {
                        setState(() {
                          _isNow = false; // For "Schedule"
                        });
                      },
                    ),
                    Text('Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        )),
                  ],
                ),
                if (!_isNow) ...[
                  SizedBox(height: 20),
                  Text("Select Date:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                  _buildDateInput(), // Long input field for date
                  SizedBox(height: 20),
                  Text("Select Time:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                  _buildTimeDropdown(), // Dropdown for time styled like input
                ],
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF379D9D), // Button color
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15), // Button padding
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 18, // Change to your desired font size
                        color:
                            Colors.white, // Change to your desired font color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Extra space before BottomNavBar
              ],
            ),
          ),
          // BottomNavigationBar Overlapping the Body
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

  Widget _buildTextInput(String initialValue, ValueChanged<String> onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10), // Adjust the radius for curvature
          borderSide:
              BorderSide.none, // Remove the border side for filled TextField
        ),
        hintText: initialValue,
        hintStyle: TextStyle(color: const Color.fromARGB(255, 83, 83, 83)),
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 12.0, // Adjust vertical padding
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return TextField(
      onTap: () {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // Prevent keyboard from showing
        _selectDate(context); // Show date picker
      },
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10), // Adjust the radius for curvature
          borderSide: BorderSide.none,
        ),
        hintText: _selectedDate == null
            ? 'Select Date'
            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
        hintStyle: TextStyle(color: const Color.fromARGB(255, 59, 59, 59)),
        contentPadding: EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 12.0), // Adjust vertical padding
      ),
    );
  }

  Widget _buildTimeDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.8),
      ),
      child: DropdownButton<String>(
        value: _selectedTime,
        hint: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0, horizontal: 12.0), // Adjust vertical padding
          child: Text(
            _selectedTime ?? 'Select Time',
            style: TextStyle(color: Color.fromARGB(255, 59, 59, 59)),
          ),
        ),
        isExpanded: true,
        underline: SizedBox(), // Remove underline
        icon: Icon(Icons.arrow_drop_down,
            color: Colors.black, size: 18), // Adjust icon size if needed
        items: _timeOptions.map((String time) {
          return DropdownMenuItem<String>(
            value: time,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 12.0), // Adjust vertical padding
              child: Text(time, style: TextStyle(color: Colors.black)),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedTime = newValue; // Update selected time
          });
        },
      ),
    );
  }
}
