import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/Theme/ThemeProvider.dart';
import 'package:demo_health/provider/settingsProvider.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:demo_health/utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../provider/reminderPRO.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ReminderProvider>(context, listen: false).loadReminders();
    Provider.of<todoProvider>(context, listen: false).getToDoDATA();
    Provider.of<SettingsProvider>(context, listen: false).initNoti();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        final settingsProvider = Provider.of<SettingsProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Padding(
          padding: EdgeInsets.only(top: 1.h, left: 2.w, right: 2.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSettingsCard('Preferences', [
                  _buildSwitchTile(
                    'Dark Mode',
                    Icons.dark_mode,
                    themeProvider.isDarkMode,
                    (value) => themeProvider.toggleTheme(value),
                  ),
                ]),
                _buildSettingsCard('Support & Information', [
                  _buildActionTile('Rate Us on App Store', Icons.star, () {
                    launchPlaystore(context: context);
                    MySnackbar().showSnackBar(
                      'Taking you to the App Store!',
                      context,
                    );
                  }),
                  _buildActionTile('Contact Support', Icons.support_agent, () {
                    launchPlaystore(context: context);
                    MySnackbar().showSnackBar(
                      'Opening email client...',
                      context,
                    );
                  }),
                  _buildInfoTile('App Version', '1.0.0', Icons.info),
                ]),
                _buildSettingsCard("Clear Data", [
                  _buildActionTile("Clear all app data", Icons.delete, () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _showDialog(
                          title: "Clear Data?",
                          text:
                              "All app data will be deleted if you press Yes.",
                          function: (value) {
                            settingsProvider.clearAllAppData();
                            Navigator.pop(context);
                          },
                          context: context,
                          yesB: "yes",
                          noB: "no",
                        );
                      },
                    );
                  }),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
      ),
      secondary: Icon(icon, color: AppColors.primary, size: 20.sp),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20.sp),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 18.sp),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
      ),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 16.sp),
      ),
    );
  }
}

Widget _showDialog({
  required String title,
  required String text,
  required void Function(bool value) function,
  required context,
  required String yesB,
  required String noB,
  bool? value,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
    title: Text(title, style: TextStyle(fontSize: 16.sp)),
    content: Text(text, style: TextStyle(fontSize: 16.sp)),
    actions: [
      MaterialButton(
        onPressed: () {
          function(value ?? true);
        },
        child: Text(yesB, style: TextStyle(fontSize: 16.sp)),
      ),
      MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
        color: AppColors.primary,
        height: 4.h,
        minWidth: 20.w,
        onPressed: () {
          Navigator.pop(context);
        },
        textColor: AppColors.background,
        child: Text(noB, style: TextStyle(fontSize: 16.sp)),
      ),
    ],
  );
}
