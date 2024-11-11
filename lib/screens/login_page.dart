import 'package:flutter/material.dart';
import '../utils/database_helper.dart'; // Import the database helper
import '../screens/registration_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_login_button.dart'; // Import the custom button widget
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DatabaseHelper dbHelper = DatabaseHelper();

      // Use the new method to get the user
      final user = await dbHelper.getUserByEmailAndPassword(email, password);

      if (user != null) {
        // Store email using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        // Navigate to the /page1 route on successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      height: 180, // Decrease the height of the header
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/logo.png',
            ),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF011A33), Color(0xFF000A14)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(), // Add the header at the top
              const SizedBox(height: 80), // Decreased space after the header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF011A33),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Email', (value) => email = value!),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Password',
                        (value) => password = value!,
                        isObscure: true,
                      ),
                      const SizedBox(height: 24),
                      CustomLoginButton(
                        onPressed: _login, // Call the _login method on press
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationPage()),
                  );
                },
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFF379D9D), // Start color
                        Color(0xFF4ECDC4), // End color
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(
                      fontSize: 16, // Adjust font size if needed
                      fontFamily: 'Russo One', // Use 'Russo One' font
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Fallback color
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Ensure this is set to true
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {bool isObscure = false}) {
    return TextFormField(
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black), // Set text color to black
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'Enter your $label', // Placeholder text
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        filled: true,
        fillColor: const Color(0xFFEFEFEF), // Light gray background
      ),
      validator: (value) => value!.isEmpty ? 'Please enter your $label' : null,
      onSaved: onSaved,
    );
  }
}
