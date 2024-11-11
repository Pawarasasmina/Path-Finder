import 'package:flutter/material.dart';

class ParkingCard extends StatelessWidget {
  final String areaName;
  final String price;
  final double rating;
  final VoidCallback? onViewButtonPressed; // Callback for the view button

  const ParkingCard({
    Key? key,
    required this.areaName,
    required this.price,
    required this.rating,
    this.onViewButtonPressed, // Accept the callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          // Image Container
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                'lib/assets/images/parking_image.jpg', // Add your parking images
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Details and Button Container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parking Area Name
                  Text(
                    areaName,
                    style: const TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Parking Price
                  Text(
                    'Rs. $price',
                    style: const TextStyle(
                      fontFamily: 'Sanchez',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Rating and View Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontFamily: 'Sanchez',
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: Color(0xFF379D9D),
                            size: 20,
                          ),
                        ],
                      ),
                      // View Button
                      GestureDetector(
                        onTap: onViewButtonPressed, // Call the callback
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF379D9D), Color(0xFF4ECDC4)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View >>',
                            style: TextStyle(
                              fontFamily: 'Sanchez',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
