import 'dart:io';

import 'package:affirmation/services/home_widget_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import '../services/notification_service.dart';
import '../models/notification_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  TimeOfDay notificationTime = const TimeOfDay(hour: 8, minute: 0);
  int notificationFrequency = 1; // 1 = Daily, 2 = Twice daily, etc.
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.getSettings();

    setState(() {
      notificationsEnabled = settings.enabled;
      notificationTime = settings.time;
      notificationFrequency = settings.frequency;
    });

    // Load theme settings here
  }

  Future<void> _saveNotificationSettings() async {
    final settings = NotificationSettings(
      enabled: notificationsEnabled,
      time: notificationTime,
      frequency: notificationFrequency,
    );

    await NotificationService.saveSettings(settings);

    if (notificationsEnabled) {
      await NotificationService.scheduleNotifications();
    } else {
      await NotificationService.cancelNotifications();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );

    if (picked != null && picked != notificationTime) {
      setState(() {
        notificationTime = picked;
      });
      await _saveNotificationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Daily Affirmations'),
            subtitle:
                const Text('Receive notifications with daily affirmations'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _saveNotificationSettings();
            },
          ),
          if (notificationsEnabled)
            ListTile(
              title: const Text('Notification Time'),
              subtitle: Text(notificationTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
          if (notificationsEnabled)
            ListTile(
              title: const Text('Frequency'),
              subtitle: Text('$notificationFrequency time(s) per day'),
              trailing: DropdownButton<int>(
                value: notificationFrequency,
                underline: Container(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      notificationFrequency = value;
                    });
                    _saveNotificationSettings();
                  }
                },
                items: [1, 2, 3].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              // Save theme settings
            },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open terms of service
            },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Home Widget',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Update Widget'),
            subtitle: const Text(
                'Update your home screen widget with a new affirmation'),
            trailing: const Icon(Icons.refresh),
            onTap: () async {
              await HomeWidgetManager.updateWidget();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Widget updated with a new affirmation')),
              );
            },
          ),
          if (Platform.isAndroid)
            ListTile(
              title: const Text('Add Widget to Home Screen'),
              subtitle: const Text('Add the BeYou widget to your home screen'),
              trailing: const Icon(Icons.add_to_home_screen),
              onTap: () async {
                await HomeWidget.requestPinWidget(
                  qualifiedAndroidName:
                      'com.beyou.affirmation.AffirmationWidgetProvider',
                );
              },
            ),
        ],
      ),
    );
  }
}
