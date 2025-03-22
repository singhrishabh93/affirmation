import 'package:affirmation/screens/home_screen.dart';
import 'package:affirmation/services/authentication_service.dart';
import 'package:affirmation/widgets/google_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  // Handle Google sign-in
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = await AuthService.signInWithGoogle();
      
      if (user != null) {
        // Navigate to home screen on successful sign in
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Sign in was canceled or failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              _isLoading
                  ? Lottie.asset('assets/loader.json', height: 50)
                  : GoogleSignInButton(
                      onPressed: _handleSignIn,
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