import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_settings.dart';
import 'affirmation_service.dart';

class NotificationService {
  static const String _settingsKey = 'notification_settings';
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static NotificationSettings _settings = NotificationSettings.defaultSettings();
  
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _loadSettings();
    
    if (_settings.enabled) {
      await scheduleNotifications();
    }
  }
  
  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = prefs.getString(_settingsKey) ?? '{}';
    
    try {
      final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
      _settings = NotificationSettings.fromJson(settingsMap);
    } catch (e) {
      _settings = NotificationSettings.defaultSettings();
    }
  }
  
  static Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    _settings = settings;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
  
  static Future<NotificationSettings> getSettings() async {
    return _settings;
  }
  
  static Future<void> scheduleNotifications() async {
    // Cancel any existing notifications first
    await cancelNotifications();
    
    if (!_settings.enabled) return;
    
    // Schedule notifications based on frequency
    for (int i = 0; i < _settings.frequency; i++) {
      await _scheduleDaily(i);
    }
  }
  
  static Future<void> _scheduleDaily(int index) async {
  // Calculate notification time based on index
  final int hoursToAdd = index * (24 ~/ _settings.frequency);
  final DateTime now = DateTime.now();

  DateTime scheduledDate = DateTime(
    now.year,
    now.month,
    now.day,
    _settings.time.hour,
    _settings.time.minute,
  );

  // Add hours if we have multiple notifications per day
  scheduledDate = scheduledDate.add(Duration(hours: hoursToAdd));

  // If the time has already passed today, schedule for tomorrow
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // Get a random affirmation for the notification
  final affirmation = await AffirmationService.getRandomAffirmation();

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'daily_affirmation',
    'Daily Affirmations',
    channelDescription: 'Daily positive affirmations to brighten your day',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  // Schedule the notification
  await _notificationsPlugin.zonedSchedule(
    index, // ID
    'Your Daily Affirmation',
    affirmation.text,
    tz.TZDateTime.from(scheduledDate, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // optional
    payload: affirmation.id,
  );
}

  static void _onNotificationTapped(NotificationResponse details) {
    // Handle notification tap
    // Navigate to the affirmation if needed
    if (details.payload != null) {
      // Can use the payload (affirmation ID) to open the specific affirmation
    }
  }
  
  static Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
  
  static Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    // if (androidPlugin != null) {
    //   // Fixed: singular 'requestPermission' instead of 'requestPermissions'
    //   await androidPlugin.requestPermission();
    // }
  }
}