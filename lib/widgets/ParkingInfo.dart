import 'package:flutter/material.dart';

class ParkingInfo extends StatelessWidget {
  final String openingHours;
  final String chargingMethod;
  final String evChargerSlots;

  const ParkingInfo({
    Key? key,
    required this.openingHours,
    required this.chargingMethod,
    required this.evChargerSlots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500, // Set the desired width here
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6E6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Center(
          // Center the content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align text to the center
            children: [
              // Opening Hours
              Text(
                'Opening Hours: $openingHours',
                style: const TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Charging Method
              Text(
                'Charging Method: $chargingMethod',
                style: const TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              // E/V Charger Slots
              Text(
                'E/V Charger Slots: $evChargerSlots',
                style: const TextStyle(
                  fontFamily: 'Sanchez',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
