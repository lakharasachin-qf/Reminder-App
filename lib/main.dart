import 'package:demo_health/views/main_screens/reminder_screen/AddEditReminderScreen.dart';
import 'package:demo_health/views/main_screens/HomeScreen.dart';
import 'package:demo_health/views/splash_screen/SplashScreen.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/Theme/ThemeProvider.dart';
import 'package:demo_health/provider/reminderPRO.dart';
import 'package:demo_health/provider/settingsProvider.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
