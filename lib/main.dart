import 'package:affirmation/screens/profile_screen.dart';
import 'package:affirmation/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:affirmation/firebase_options.dart'; // Import Firebase options
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart'; // Add this import
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/affirmation_service.dart';
import 'services/notification_service.dart';
import 'services/home_widget_manager.dart'; // Add this import

// Add this callback function outside of any class
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  if (data?.host == 'titleclicked') {
    // Handle the interaction
    await HomeWidget.setAppGroupId('com.beyou.affirmation');
    await interactivityCallback(data);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FCMService.initialize();
  
  await AffirmationService.initialize();
  await NotificationService.initialize();
  
  // Initialize HomeWidget
  await HomeWidget.setAppGroupId('com.beyou.affirmation');
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  await HomeWidgetManager.initialize(); // Add widget initialization

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Hide bottom navigation bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeYou - Positive Vibes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFD5EAE4),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.4,
          ),
          bodyLarge: GoogleFonts.merriweather(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}