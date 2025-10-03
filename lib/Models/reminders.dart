import 'dart:math';
import 'package:flutter/material.dart';

class HealthReminder {
  final int id;
  final String title;
  final TimeOfDay? time;
  final String frequency;
  final String iconName; // store icon name instead of IconData
  final Color color;
  bool? isActive = true;

  HealthReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
    required this.iconName,
    required this.color,
    this.isActive,
  });

  // Convert string -> IconData (const)
  IconData get icon {
    switch (iconName) {
      case 'alarm':
        return Icons.alarm;
      case 'medication':
        return Icons.medication;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.notifications;
    }
  }

  int? _timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': _timeToMinutes(time),
    'frequency': frequency,
    'iconName': iconName,
    'color': color.value,
    'isActive': isActive,
  };

  factory HealthReminder.fromJson(Map<String, dynamic> json) => HealthReminder(
    id: (json['id'] is int)
        ? (json['id'] as int) & 0x7FFFFFFF
        : Random().nextInt(0x7FFFFFFF),
    title: json['title'] ?? '',
    time: json['time'] != null
        ? TimeOfDay(
            hour: (json['time'] as int) ~/ 60,
            minute: (json['time'] as int) % 60,
          )
        : null,
    frequency: json['frequency'] ?? 'Daily',
    iconName: json['iconName'] ?? 'medication',
    color: Color(json['color'] ?? Colors.blue.value),
    isActive: json['isActive'] ?? true,
  );
}
