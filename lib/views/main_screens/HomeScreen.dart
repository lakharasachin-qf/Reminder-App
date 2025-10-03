import 'package:demo_health/notiServices/noti_Services.dart';
import 'package:demo_health/views/main_screens/calender_screen/CalenderScreenTodo.dart';
import 'package:demo_health/views/main_screens/reminder_screen/RemindersList.dart';
import 'package:demo_health/views/main_screens/settings_screen/SettingsPage.dart';
import 'package:demo_health/Services/SharedPrefServices.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Sharedprefservices sharedprefservices = Sharedprefservices();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    initNotifications();
  }

  void initNotifications() async {
    await NotiServices().initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const RemindersList(),
      CalenderScreen(),
      const SettingsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['My Health Hub', 'Health Tasks', 'Settings'][_selectedIndex],
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  )
                : LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  colors: [
                    AppColors.darkBackground.withOpacity(0.5),
                    AppColors.darkSurface.withOpacity(0.5),
                  ],
                )
              : AppColors.backgroundGradient,
        ),
        child: IndexedStack(index: _selectedIndex, children: widgetOptions),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/add_edit_reminder',
                );
                if (result == true) {
                  await sharedprefservices.getReminder();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,

      bottomNavigationBar: GNav(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primary,
        rippleColor: AppColors.success.withOpacity(0.2),
        hoverColor: AppColors.primaryDark, // tab button hover color
        haptic: false,
        tabBorderRadius: 0,
        duration: Duration(milliseconds: 300),
        gap: 8,
        color: AppColors.success, // unselected icon color
        activeColor: AppColors.background, // selected icon and text color
        iconSize: 30, // tab button icon size
        tabBackgroundColor: AppColors.primary.withOpacity(
          0.5,
        ), // selected tab background color

        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ), // navigation bar padding
        tabs: [
          GButton(icon: Icons.medical_services_outlined, text: 'Reminders'),
          GButton(icon: Icons.task_alt_outlined, text: 'Tasks'),
          GButton(icon: Icons.settings_outlined, text: 'Settings'),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.medical_services_outlined),
      //       activeIcon: Icon(Icons.medical_services),
      //       label: 'Reminders',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.task_alt_outlined),
      //       activeIcon: Icon(Icons.task_alt),
      //       label: 'Tasks',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings_outlined),
      //       activeIcon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

// Consolas, 'Courier New', monospace (default fontFamily of editor).
