import 'package:affirmation/screens/home_screen.dart';
import 'package:affirmation/widgets/google_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  // Handle Google sign-in
  void _handleSignIn(BuildContext context) {
    // In a real implementation, you would handle Google authentication here
    // For now, we'll just navigate to the home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon could go here
              
              // App Title
              Text(
                "BeYou",
                style: GoogleFonts.indieFlower(
                  fontSize: 85,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Subtitle
              Text(
                "Daily Affirmations",
                style: GoogleFonts.indieFlower(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Google Sign-in Button
              GoogleSignInButton(
                onPressed: () => _handleSignIn(context),
              ),
              
              const SizedBox(height: 24),
              
              // Terms and Policy text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "By signing in, you agree to our Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.black54,
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