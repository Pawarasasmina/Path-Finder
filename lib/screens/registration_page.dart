import 'package:flutter/material.dart';
import '../utils/database_helper.dart'; // Import the database helper
import '../screens/login_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_register_button.dart'; // Import the custom register button widget

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String contactNumber = '';
  String vehicleNumber = '';
  String password = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create user data map
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'contactNumber': contactNumber,
        'vehicleNumber': vehicleNumber,
        'password': password, // Ideally, you should hash the password
      };

      // Insert user data into the database
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.insertUser(userData);

      // Navigate to the LoginPage after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
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
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF011A33),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Name', (value) => name = value!),
                      const SizedBox(height: 16),
                      _buildTextField('Email', (value) => email = value!),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Contact Number', (value) => contactNumber = value!),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Vehicle Number', (value) => vehicleNumber = value!),
                      const SizedBox(height: 16),
                      _buildTextField('Password', (value) => password = value!,
                          isObscure: true),
                      const SizedBox(height: 24),
                      CustomRegisterButton(
                        onPressed:
                            _register, // Call the _register method on press
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
                    MaterialPageRoute(builder: (context) => const LoginPage()),
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
                    'Already have an account? Login here',
                    style: TextStyle(
                      fontSize: 16, // Adjust font size if needed
                      fontFamily: 'Russo One', // Use 'Russo One' font
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Fallback color
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
      style:
          const TextStyle(color: Colors.black), // Set the font color to black
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'Enter your $label',
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
