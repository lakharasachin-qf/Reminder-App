import 'dart:math';
import 'package:flutter/material.dart';

class HealthReminder {
  final int id;
  final String title;
  final TimeOfDay? time;
  final String frequency;
  final IconData icon;
  final Color color;
  bool? isActive = true;

  HealthReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
    required this.icon,
    required this.color,
    this.isActive,
  });

  int? _timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  // TimeOfDay? _minutesToTime(int? minutes) {
  //   if (minutes == null) return null;
  //   return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  // }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': _timeToMinutes(time),
    'frequency': frequency,
    'icon': icon.codePoint,
    'color': color.value,
    'isActive': isActive,
  };

  factory HealthReminder.fromJson(Map<String, dynamic> json) => HealthReminder(
    id: (json['id'] is int)
        ? (json['id'] as int) &
              0x7FFFFFFF // force into 32-bit positive int
        : Random().nextInt(0x7FFFFFFF),
    title: json['title'] ?? '',
    time: json['time'] != null
        ? TimeOfDay(
            hour: (json['time'] as int) ~/ 60,
            minute: (json['time'] as int) % 60,
          )
        : null,
    frequency: json['frequency'] ?? 'Daily',
    icon: IconData(
      json['icon'] ?? Icons.medication.codePoint,
      fontFamily: 'MaterialIcons',
    ),
    color: Color(json['color'] ?? Colors.blue.value),
    isActive: json['isActive'] ?? true,
  );
}
