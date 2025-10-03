import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiServices {
  static final NotiServices _instance = NotiServices._internal();
  factory NotiServices() => _instance;
  NotiServices._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    print("initNotifications called");
    try {
      tz.initializeTimeZones();

      // Get the timezone identifier as a String from TimezoneInfo
      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();
      String currentTimezone = timezoneInfo.identifier;

      // Map deprecated timezone names to valid ones
      if (currentTimezone == 'Asia/Calcutta') {
        currentTimezone = 'Asia/Kolkata';
      }

      // Verify if the timezone is valid
      try {
        tz.setLocalLocation(tz.getLocation(currentTimezone));
      } catch (e) {
        print(
          "Invalid timezone: $currentTimezone. Falling back to Asia/Kolkata",
        );
        currentTimezone = 'Asia/Kolkata';
        tz.setLocalLocation(tz.getLocation(currentTimezone));
      }

      const AndroidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(android: AndroidSettings);

      await notificationPlugin.initialize(initializationSettings);

      await notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await notificationPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      print("Notification initialized");
    } catch (e) {
      print("Error in initNotifications: $e");
    }
  }

  Future<void> instantNotification({
    required String title,
    required int id,
    required String body,
  }) async {
    try {
      await notificationPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'noti_first',
            'Instant Notification',
            channelDescription: 'Instant notification channel',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            enableLights: true,
            fullScreenIntent: true,
            playSound: true,
            autoCancel: true,
          ),
        ),
      );
      print("Instant notification sent");
    } catch (e) {
      print("Error in instantNotification: $e");
    }
  }

  Future<void> reminderNoti({
    required int id,
    required String title,
    required String body,
    required Color color1,
    required String frequency,
    required TimeOfDay time,
  }) async {
    print("Scheduling reminder notification");
    try {
      // Check if exact alarm permission is granted (Android 12+)
      final androidPlugin = notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      bool canScheduleExact = true;

      if (androidPlugin != null) {
        final bool? granted = await androidPlugin
            .requestExactAlarmsPermission();
        if (granted != true) {
          print("Exact alarm permission denied, using inexact scheduling");
          canScheduleExact = false;
        }
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'channelId',
            'Channel Name',
            priority: Priority.high,
            importance: Importance.max,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            color: color1,
            colorized: true,
            fullScreenIntent: true,
            icon: '@mipmap/ic_notification',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_notification'),
          );

      final NotificationDetails notiDetails = NotificationDetails(
        android: androidDetails,
      );

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notiDetails,
        androidScheduleMode: canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: frequency == 'Daily'
            ? DateTimeComponents.time
            : frequency == 'Weekly'
            ? DateTimeComponents.dayOfWeekAndTime
            : frequency == 'Monthly'
            ? DateTimeComponents.dayOfMonthAndTime
            : null,
      );

      print('Reminder notification scheduled successfully');
    } catch (e) {
      print("Error in reminderNoti: $e");
      rethrow; // Rethrow to allow caller to handle the error
    }
  }
}
