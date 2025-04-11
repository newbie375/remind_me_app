import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class AlarmPermissionService {
  Future<bool> requestExactAlarmPermission() async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
      return true; // Assume permission is granted after launching settings
    } catch (e) {
      return false; // Return false if an error occurs
    }
  }
}