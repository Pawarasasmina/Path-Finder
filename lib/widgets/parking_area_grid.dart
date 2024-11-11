import 'package:flutter/material.dart';

class ParkingAreaGrid extends StatelessWidget {
  const ParkingAreaGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEFE6E6), // Background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row (Slots 01, 03, 05, 06, 07)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Slot 01
                _buildSlotContainer('01'),
                // Slot 03
                _buildSlotContainer('03'),
                // Slot 05
                _buildSlotContainer('05'),
                // Slot 06
                _buildSlotContainer('06'),
                // Slot 07
                _buildSlotContainer('07'),
              ],
            ),
            const SizedBox(height: 16),
            // Divider (Dashed line)
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0), // Add padding to move right
              child: Row(
                children: List.generate(
                  8, // Dashed line segment count
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 5,
                      color: (index % 2 == 0)
                          ? const Color(0xFF292F36)
                          : Colors.transparent, // Dashed effect
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bottom Row (Slots 02, 04)
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                // Slot 02
                _buildSlotContainer('02'),
                const SizedBox(
                    width: 20), // Add space between Slot 02 and Slot 04
                // Slot 04 (Move left)
                _buildSlotContainer('04'),
                const SizedBox(width: 32), // Increased space before X icon
                // Center X Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4), // Border color
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Color(0xFF4ECDC4), // X Icon color
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Placeholder (Dashed line on the right)
                Container(
                  width: 120, // Increased width for dashed line
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotContainer(String slotNumber) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4), // Slot color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          slotNumber, // Display the slot number
          style: const TextStyle(
            fontFamily: 'Russo One', // Set the font family to Russo One
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
