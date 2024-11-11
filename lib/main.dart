import 'package:flutter/material.dart';
import './screens/path_finder_screen.dart'; // Import your PathFinderScreen
import './screens/MapScreen.dart';
import './screens/HomePage.dart';
import './screens/park_selection_screen.dart';
import './screens/login_page.dart'; // Import the login page
import './screens/page1.dart'; // Import the page1 screen
import './screens/splash_screen.dart'; // Import the SplashScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Set the initial route to SplashScreen
      routes: {
        '/splash': (context) => SplashScreen(), // Add splash screen route
        '/parkselection': (context) => const ParkSelection(),
        '/mapModel': (context) => MapModelScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/page1': (context) => Page1(),
        '/pathfinder': (context) => PathFinderScreen(),
      },
    );
  }
}
