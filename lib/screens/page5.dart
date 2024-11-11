import 'package:flutter/material.dart';

class Page5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Parking Slots'),
      ),
      body: Center(
        child: const Text(
          'Available Parking Slots Found!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
