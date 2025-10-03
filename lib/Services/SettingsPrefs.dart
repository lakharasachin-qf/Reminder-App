import 'package:shared_preferences/shared_preferences.dart';

class SettingsPrefs {
  static final SettingsPrefs _instance = SettingsPrefs._internal();
  factory SettingsPrefs() => _instance;
  SettingsPrefs._internal();

  bool isNotiON = true;

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isNotiON = prefs.getBool('notiON') ?? true;
  }

  Future<void> getNotificationstate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isNotiON = prefs.getBool('notiON') ?? true;
  }

  Future<void> saveNotificationUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notiON', isNotiON);
  }
}
