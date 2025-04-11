import 'package:flutter/material.dart';
import 'package:remind_me_app/infrastructure/datasources/database_helper.dart';
import 'package:remind_me_app/infrastructure/services/alarm_permission_service.dart';
import 'package:android_intent_plus/android_intent.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;

  const NotificationPermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  Future<void> _grantPermission() async {
    debugPrint('Granting notification permission');
    final isPermissionGranted = await AlarmPermissionService().requestExactAlarmPermission();

    if (!mounted) return; // Ensure the widget is still mounted

    if (isPermissionGranted) {
      await DatabaseHelper().setFirstLaunch(false);
      debugPrint('Notification permission granted');
      widget.onPermissionGranted();
    } else {
      // Show a dialog to guide the user to system settings
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'This app requires the "Exact Alarms" permission to schedule notifications. Please enable it in the system settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openSystemSettings();
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openSystemSettings() {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'This app requires notification permissions to remind you of important tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _grantPermission,
              child: const Text('Allow Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}