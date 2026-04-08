import 'package:flutter/material.dart';

class RegistrationBlockedScreen extends StatelessWidget {
  const RegistrationBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 80,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 30),

              /// TITLE
              const Text(
                "Registration Closed",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              /// MESSAGE
              const Text(
                "Student registration is currently disabled by the admin.\n\nPlease try again later.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}