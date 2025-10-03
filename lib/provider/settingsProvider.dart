import 'package:demo_health/Services/SettingsPrefs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/SharedPrefServices.dart';
import '../Services/todoPrefs.dart';
import '../notiServices/noti_Services.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsPrefs settingsPrefs = SettingsPrefs();

  Future<void> initNoti() async {
    await settingsPrefs.getNotificationstate();
    notifyListeners();
  }

  Future<void> clearAllAppData() async {
    print("Deleting all app data");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Sharedprefservices().reminderList.clear();
      todoDatabase().todoList.clear();
      await prefs.clear();
      await NotiServices().notificationPlugin.cancelAll();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value, BuildContext context) async {
    try {
      print("Toggling notifications: $value");
      settingsPrefs.isNotiON = value;
      await settingsPrefs.saveNotificationUpdate();

      if (!value) {
        // Disable all notifications
        await NotiServices().notificationPlugin.cancelAll();
        print("Notifications disabled");
      } else {
        // Re-enable notifications by scheduling all active reminders
        final reminders = Sharedprefservices().reminderList;
        for (final reminder in reminders) {
          if (reminder.isActive ?? true) {
            await NotiServices().reminderNoti(
              id: reminder.id,
              title: reminder.title,
              // ignore: use_build_context_synchronously
              body: '${reminder.time?.format(context)} • ${reminder.frequency}',
              frequency: reminder.frequency,
              time: reminder.time!,
              color1: reminder.color,
            );
          }
        }
        print("Notifications enabled and reminders rescheduled");
      }
    } catch (e) {
      print("Error in toggleNotifications: $e");
    }

    notifyListeners();
  }
}
