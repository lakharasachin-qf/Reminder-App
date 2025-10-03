import 'package:smart_reminder/views/main_screens/reminder_screen/AddEditReminderScreen.dart';
import 'package:smart_reminder/views/main_screens/HomeScreen.dart';
import 'package:smart_reminder/views/splash_screen/SplashScreen.dart';
import 'package:smart_reminder/Theme/AppTheme.dart';
import 'package:smart_reminder/Theme/ThemeProvider.dart';
import 'package:smart_reminder/notiServices/noti_Services.dart';
import 'package:smart_reminder/provider/reminderPRO.dart';
import 'package:smart_reminder/provider/settingsProvider.dart';
import 'package:smart_reminder/provider/toDoPro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotiServices().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => todoProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Smart Health Reminder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_edit_reminder': (context) =>
            const AddEditReminderScreen(isEdit: false),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
