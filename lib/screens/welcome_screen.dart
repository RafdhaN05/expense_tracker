import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Detect whether the app is currently in Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Dynamic background: Deep navy in Dark Mode, Warm Cream in Light Mode!
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.warmCream,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top empty space to center the illustration nicely
              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  'assets/images/welcome_cat.png',
                  // Scale relative to screen width for responsiveness
                  width: screenSize.width * 0.75,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue, // Brand blue color
                    foregroundColor: Colors.white,         // White button text
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Smooth pill shape
                    ),
                  ),
                  onPressed: () {
                    // NAVIGATION LOGIC:
                    // Smoothly navigate from WelcomeScreen to SignInScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}