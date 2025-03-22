import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './firestore_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Initialize FCM
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    
    print('FCM User permission status: ${settings.authorizationStatus}');
    
    // Handle token refreshes
    _messaging.onTokenRefresh.listen((token) {
      _updateToken(token);
    });
    
    // Get initial token
    String? token = await _messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      _updateToken(token);
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
  
  // Update token in Firestore
  static Future<void> _updateToken(String token) async {
    User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      try {
        await FirestoreService.updateFcmToken(currentUser.uid);
      } catch (e) {
        print('Error updating FCM token: $e');
      }
    }
  }
}