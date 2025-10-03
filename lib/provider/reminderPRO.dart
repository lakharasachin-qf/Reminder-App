import 'package:demo_health/Services/SharedPrefServices.dart';
import 'package:demo_health/notiServices/noti_Services.dart';
import 'package:flutter/material.dart';
import '../Models/reminders.dart';

class ReminderProvider extends ChangeNotifier {
  final Sharedprefservices _sharedPrefs = Sharedprefservices();
  List<HealthReminder> get reminders => _sharedPrefs.reminderList;

  void deleteReminder(int index) {
    final reminderId = _sharedPrefs.reminderList[index].id;
    _sharedPrefs.reminderList.removeAt(index);
    _sharedPrefs.saveReminder();
    try {
      print("Snoti is deleting");
      NotiServices().notificationPlugin.cancel(reminderId);
      print("Snoti deleted");
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadReminders() async {
    await _sharedPrefs.getReminder();
    notifyListeners();
  }

  Future<void> addReminder(HealthReminder reminder) async {
    print("add RR st");
    try {
      _sharedPrefs.reminderList.add(reminder);
      await _sharedPrefs.saveReminder();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
    print("addRR end");
  }

  void updateReminder(HealthReminder updateReminder) {
    final index = reminders.indexWhere((r) => r.id == updateReminder.id);
    if (index != -1) {
      reminders[index] = updateReminder;
      _sharedPrefs.saveReminder();
      notifyListeners();
    }
  }

  Future<void> toggleReminderActive(
    int index,
    bool value,
    BuildContext context,
  ) async {
    _sharedPrefs.reminderList[index].isActive = value;
    await _sharedPrefs.saveReminder();

    final reminder = _sharedPrefs.reminderList[index];

    if (value) {
      print("timer saved");
      await NotiServices().reminderNoti(
        id: reminder.id,
        title: reminder.title,
        body: '${reminder.time?.format(context)} • ${reminder.frequency}',
        frequency: reminder.frequency,
        time: reminder.time!,
        color1: reminder.color,
      );
    } else {
      await NotiServices().notificationPlugin.cancel(reminder.id);
      print("timer cancel P");
    }
    notifyListeners();
  }
}
