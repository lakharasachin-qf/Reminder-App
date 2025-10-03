import 'package:demo_health/Theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

void launchPlaystore({required context}) async {
  final Uri playStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.example.demo_health',
  );

  final Uri uri = playStoreUrl;

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $playStoreUrl';
  }
}
