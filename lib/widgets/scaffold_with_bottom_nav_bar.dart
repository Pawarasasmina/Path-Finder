import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart'; // Ensure you import your CustomAppBar

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget bodyContent;
  final int currentIndex;
  final String appBarTitle; // Title for the CustomAppBar
  final VoidCallback onBackPressed; // Callback for back button

  const ScaffoldWithBottomNavBar({
    Key? key,
    required this.bodyContent,
    required this.currentIndex,
    required this.appBarTitle, // Include appBarTitle in the constructor
    required this.onBackPressed, // Include onBackPressed in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: appBarTitle, // Use the provided title
        onBackPressed: onBackPressed, // Pass the back button callback
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              parentContext: context,
              currentIndex: currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}
