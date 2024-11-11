import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class DisplayIDPage extends StatefulWidget {
  const DisplayIDPage({Key? key}) : super(key: key);

  @override
  _DisplayIDPageState createState() => _DisplayIDPageState();
}

class _DisplayIDPageState extends State<DisplayIDPage> {
  String? savedQrData;
  bool isLoading = false; // New loading state variable
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadSavedQrData();
  }

  Future<void> _loadSavedQrData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    // Delay for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedQrData = prefs.getString('qrData') ?? 'No QR data found.';
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Path Finder',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF011A33), Color(0xFF000A14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    if (isLoading) // Show loading spinner if loading
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4ECDC4)), // Change spinner color
                      )
                    else if (savedQrData != null &&
                        savedQrData != 'No QR data found.')
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: CustomPaint(
                          size: const Size(250, 250),
                          painter: QrPainter(
                            data: savedQrData!,
                            version: QrVersions.auto,
                            gapless: false,
                            color: const Color(0xFF000000),
                            emptyColor: const Color(0xFFFFFFFF),
                          ),
                        ),
                      )
                    else if (savedQrData == 'No QR data found.')
                      const Text(
                        'No saved QR code data found.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 5,
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 30),
                    // Show button only if not loading
                    if (!isLoading) // Button to refresh or reload QR data
                      GestureDetector(
                        onTap: _loadSavedQrData,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF379D9D), Color(0xFF4ECDC4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Refresh QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
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
}
