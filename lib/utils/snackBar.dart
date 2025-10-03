import 'package:demo_health/Theme/AppTheme.dart';
import 'package:flutter/material.dart';

class MySnackbar {
  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

Future<void> _launchInBrowser(String url) async {
  if (await UrlLauncherPlatform.instance.canLaunch(url)) {
    await UrlLauncherPlatform.instance.launch(
      url,
      useSafariVC: false,
      useWebView: false,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{},
    );
  } else {
    throw Exception('Could not launch $url');
  }
}
