import 'package:affirmation/screens/Auth/signIn_screen.dart';
import 'package:affirmation/screens/home_screen.dart';
import 'package:affirmation/services/affirmation_service.dart';
import 'package:affirmation/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;
  String _loadingText = "Loading...";

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Create fade-out animation
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    // Load data and check authentication state
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // First, fetch and cache affirmations
      setState(() {
        _loadingText = "Fetching affirmations...";
      });
      await AffirmationService.initialize();
      
      // Then check authentication
      setState(() {
        _loadingText = "Checking login...";
      });
      final bool isLoggedIn = await AuthService.isLoggedIn();
      
      // Briefly delay to show splash screen
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _isLoading = false;
      });
      
      // Start animation
      _controller.forward();
      
      // Navigate when animation completes
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => isLoggedIn 
                    ? const HomeScreen() 
                    : const SignInScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error in app initialization: $e');
      // Handle error, possibly show error state or retry button
      setState(() {
        _loadingText = "Error loading data. Please try again.";
        _isLoading = false;
      });
      // Start animation after a delay anyway to navigate to the app
      await Future.delayed(const Duration(seconds: 2));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "BeYou",
                    style: GoogleFonts.indieFlower(
                      fontSize: 85,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_isLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      _loadingText,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}