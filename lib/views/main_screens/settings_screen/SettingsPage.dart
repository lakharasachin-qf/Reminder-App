import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/Theme/ThemeProvider.dart';
import 'package:demo_health/provider/settingsProvider.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:demo_health/utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSettingsCard('Preferences', [
              // _buildSwitchTile(
              //   'Enable Notifications',
              //   Icons.notifications,
              //   settingsProvider.settingsPrefs.isNotiON,
              //   // (value) => settingsProvider.toggleNotifications(value),
              //   (value) {
              //     print("the button");
              //     if (!value) {
              //       showDialog(
              //         context: context,
              //         builder: (context) {
              //           return _showDialog(
              //             title: "Warning",
              //             text: "All the app notifications will be canceled",
              //             function: (value) {
              //               print("object");
              //               settingsProvider.toggleNotifications(
              //                 value,
              //                 context,
              //               );
              //               settingsProvider.settingsPrefs
              //                   .saveNotificationUpdate();
              //               Navigator.pop(context);
              //               // setState(() {});
              //             },
              //             context: context,
              //             yesB: "Agree",
              //             noB: "Disagree",
              //             value: value,
              //           );
              //         },
              //       );
              //     } else {
              //       settingsProvider.toggleNotifications(value, context);
              //       settingsProvider.settingsPrefs.saveNotificationUpdate();
              //     }
              //   },
              // ),
              _buildSwitchTile(
                'Dark Mode',
                Icons.dark_mode,
                themeProvider.isDarkMode,
                (value) => themeProvider.toggleTheme(value),
              ),
            ]),
            // const SizedBox(height: 16),
            _buildSettingsCard('Support & Information', [
              _buildActionTile('Rate Us on App Store', Icons.star, () {
                MySnackbar().showSnackBar(
                  'Taking you to the App Store!',
                  context,
                );
              }),
              _buildActionTile('Contact Support', Icons.support_agent, () {
                MySnackbar().showSnackBar('Opening email client...', context);
              }),
              _buildInfoTile('App Version', '1.0.0', Icons.info),
            ]),

            _buildSettingsCard("Cleat Data", [
              _buildActionTile("Clear all app data", Icons.delete, () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return _showDialog(
                      title: "Clear Data?",
                      text:
                          "All the in app data will disappear when you hit yes",
                      function: (value) {
                        settingsProvider.clearAllAppData();
                        Navigator.pop(context);
                      },
                      context: context,
                      yesB: "yes",
                      noB: "no",
                    );
                    //return _showDialog(title, text, function, context, yesB, noB)
                  },
                );
              }),
            ]),
            // const SizedBox(height: 24),
            // const AboutListTile(
            //   icon: Icon(Icons.favorite, color: AppColors.primary),
            //   applicationName: 'Smart Health Reminder',
            //   applicationVersion: '1.0.0',
            //   applicationLegalese: '© 2025 Health App Team',
            //   aboutBoxChildren: [Text('Your health, our priority.')],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 8),
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
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      secondary: Icon(icon, color: AppColors.primary),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
    );
  }

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: AppColors.primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       margin: const EdgeInsets.all(16),
  //     ),
  //   );
  // }
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(title),
    content: Text(text, style: TextStyle(fontSize: 15)),
    actions: [
      MaterialButton(
        onPressed: () {
          print("dialog");
          function(value ?? true);
        },
        child: Text(yesB),
      ),
      MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.primary,
        height: 35,
        minWidth: 85,
        onPressed: () {
          Navigator.pop(context);
        },
        textColor: AppColors.background,
        child: Text(noB),
      ),
    ],
  );
}
