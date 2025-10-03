import 'dart:convert';
import 'package:demo_health/Models/reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sharedprefservices {
  static final Sharedprefservices _instance = Sharedprefservices._internal();
  factory Sharedprefservices() => _instance;
  Sharedprefservices._internal();

  List<HealthReminder> reminderList = [];

  Future<void> saveReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> reminderListString = reminderList
        .map((x) => jsonEncode(x.toJson()))
        .toList();
    await prefs.setStringList('reminderList', reminderListString);
  }

  Future<void> getReminder() async {
    // call setState
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? reminderListString = prefs.getStringList('reminderList');
    if (reminderListString != null) {
      reminderList = reminderListString
          .map((x) => HealthReminder.fromJson(jsonDecode(x)))
          .toList();
    }
  }
}