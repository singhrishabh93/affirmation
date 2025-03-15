import 'package:flutter/material.dart';

class NotificationSettings {
  final bool enabled;
  final TimeOfDay time;
  final int frequency;

  NotificationSettings({
    required this.enabled,
    required this.time,
    required this.frequency,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? false,
      time: TimeOfDay(
        hour: json['hour'] ?? 8, 
        minute: json['minute'] ?? 0,
      ),
      frequency: json['frequency'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'hour': time.hour,
      'minute': time.minute,
      'frequency': frequency,
    };
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      enabled: false,
      time: const TimeOfDay(hour: 8, minute: 0),
      frequency: 1,
    );
  }
}