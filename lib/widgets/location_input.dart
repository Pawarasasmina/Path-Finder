import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  final Function(String) onStartingLocationChanged;
  final Function(String) onEndingLocationChanged;
  final FocusNode startingLocationFocusNode = FocusNode();
  final FocusNode endingLocationFocusNode = FocusNode();

  LocationInput({
    required this.onStartingLocationChanged,
    required this.onEndingLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Color(0xFF265656); // Set your desired border color here

    return GestureDetector(
      onTap: () {
        // Unfocus both TextFields when tapping anywhere else on the screen
        FocusScope.of(context).unfocus(); // Dismiss keyboard and unfocus
      },
      child: Row(
        children: [
          // Starting Location TextField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the text field
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Shadow color
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                focusNode: startingLocationFocusNode, // Set the focus node
                onChanged: onStartingLocationChanged, // Call the callback
                decoration: InputDecoration(
                  labelText: 'Starting Location',
                  labelStyle: TextStyle(color: borderColor), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Rounded corners for the outline
                    borderSide: BorderSide(
                        color: borderColor,
                        width: 1), // Set border color and width
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: borderColor, width: 1), // Border when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: borderColor, width: 2), // Border when focused
                  ),
                  filled: true,
                  fillColor: Colors.white, // Fill color for the text field
                  prefixIcon:
                      Icon(Icons.location_on, color: borderColor), // Icon color
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          // Ending Location TextField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the text field
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Shadow color
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                focusNode: endingLocationFocusNode, // Set the focus node
                onChanged: onEndingLocationChanged, // Call the callback
                decoration: InputDecoration(
                  labelText: 'Ending Location',
                  labelStyle: TextStyle(color: borderColor), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Rounded corners for the outline
                    borderSide: BorderSide(
                        color: borderColor,
                        width: 1), // Set border color and width
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: borderColor, width: 1), // Border when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: borderColor, width: 2), // Border when focused
                  ),
                  filled: true,
                  fillColor: Colors.white, // Fill color for the text field
                  prefixIcon:
                      Icon(Icons.location_on, color: borderColor), // Icon color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
