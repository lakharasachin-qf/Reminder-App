import 'package:smart_reminder/notiServices/noti_Services.dart';
import 'package:smart_reminder/views/main_screens/calender_screen/CalenderScreenTodo.dart';
import 'package:smart_reminder/views/main_screens/reminder_screen/RemindersList.dart';
import 'package:smart_reminder/views/main_screens/settings_screen/SettingsPage.dart';
import 'package:smart_reminder/Services/SharedPrefServices.dart';
import 'package:smart_reminder/Theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sizer/sizer.dart';

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
    // initNotifications();
  }

  // void initNotifications() async {
  //   await NotiServices().initNotifications();
  // }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        final List<Widget> widgetOptions = <Widget>[
          const RemindersList(),
          CalenderScreen(),
          const SettingsPage(),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              ['My Reminders', 'Tasks', 'Settings'][_selectedIndex],
              style: TextStyle(fontSize: 16.sp),
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
                  icon: Icon(Icons.add, size: 18.sp),
                  label: Text(
                    'Add Reminder',
                    style: TextStyle(fontSize: 14.sp),
                  ),
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
            hoverColor: AppColors.primaryDark,
            haptic: false,
            tabBorderRadius: 0,
            duration: Duration(milliseconds: 300),
            gap: 2.w,
            color: AppColors.success,
            activeColor: AppColors.background,
            iconSize: 18.sp,
            tabBackgroundColor: AppColors.primary.withOpacity(0.5),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            tabs: [
              GButton(
                icon: Icons.medical_services_outlined,
                text: 'Reminders',
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: _selectedIndex == 0
                      ? AppColors.background
                      : AppColors.success,
                ),
              ),
              GButton(
                icon: Icons.task_alt_outlined,
                text: 'Tasks',
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: _selectedIndex == 1
                      ? AppColors.background
                      : AppColors.success,
                ),
              ),
              GButton(
                icon: Icons.settings_outlined,
                text: 'Settings',
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: _selectedIndex == 2
                      ? AppColors.background
                      : AppColors.success,
                ),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        );
      },
    );
  }
}
