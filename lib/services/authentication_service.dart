import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
  try {
    // Force the Google Sign In flow to show every time
    await _googleSignIn.signOut();
    
    // Begin interactive sign in process
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    
    if (user != null) await _saveUserToPrefs(user);
    return user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}
  
  // Save user data to SharedPreferences
  static Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a map of user data
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
      };
      
      // Save to SharedPreferences
      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
  
  // Get current user from SharedPreferences
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) return null;
      
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) return null;
      
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}