import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiServices {
  static final NotiServices _instance = NotiServices._internal();
  factory NotiServices() => _instance;
  NotiServices._internal();

  FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // static final Sharedprefservices _instance = Sharedprefservices._internal();
  // factory Sharedprefservices() => _instance;
  // Sharedprefservices._internal();
  Future<void> initNotifications() async {
    print("initNotifications called");
    try {
      tz.initializeTimeZones();

      final String currentTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimezone));

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

      print("notification initialized");
    } catch (e) {
      print("Error in initNotifications: $e");
    }
  }

  Future<void> instantNotification({
    required String title,
    required id,
    required body,
  }) async {
    try {
      print("noti sent");
      await notificationPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'noti_first',
            'instant noti',
            channelDescription: 'instant notification channel',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            enableLights: true,
            fullScreenIntent: true,
            playSound: true,
            autoCancel: true,
          ), //887777
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> reminderNoti({
    required int id,
    required String title,
    required String body,
    required Color color1,
    required String frequency,
    required TimeOfDay time, // Make sure this is TimeOfDay
  }) async {
    print("noti called (reminderNoti)");
    try {
      print("Snoti init");
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

      // ignore: non_constant_identifier_names
      final AndroidDetails = AndroidNotificationDetails(
        'channelId',
        'channel Name',
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
        // styleInformation: const BigPictureStyleInformation(
        //   FilePathAndroidBitmap(''), // Provide a valid file path here
        //   largeIcon: FilePathAndroidBitmap(''),
        // ),
      );

      final notiDetails = NotificationDetails(android: AndroidDetails);

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notiDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // matchDateTimeComponents: DateTimeComponents.time,
        matchDateTimeComponents: frequency == 'Daily'
            ? DateTimeComponents.time
            : frequency == 'Weekly'
            ? DateTimeComponents.dayOfWeekAndTime
            : frequency == 'Monthly'
            ? DateTimeComponents.dayOfMonthAndTime
            : null,
      );
      print('Snoti sent');
    } catch (e) {
      print(e.toString());
    }
  }
}
