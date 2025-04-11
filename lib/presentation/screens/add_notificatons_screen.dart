import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remind_me_app/infrastructure/datasources/database_helper.dart';
import 'package:remind_me_app/infrastructure/services/alarm_permission_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedRepeatOption = 'Does not repeat';

  final List<String> _repeatOptions = [
    'Does not repeat',
    'Every day',
    'Every week',
    'Every month',
    'Every year',
    'Custom',
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _scheduleNotification(
      String name, DateTime dateTime, String repeatOption) async {
    // Define notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel', // Channel ID
      'Reminders', // Channel name
      channelDescription: 'Notification channel for reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      name, // Notification title
      'Reminder scheduled for $dateTime', // Notification body
      tzDateTime, // Schedule time
      platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.time, // Correct parameter
      androidScheduleMode: AndroidScheduleMode.exact, // Correct parameter
    );
  }

  void _saveNotification() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty || _selectedDate == null || _selectedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a name, date, and time')),
        );
      }
      return;
    }

    final DateTime notificationDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    debugPrint('Saving notification: $name at $notificationDateTime');

    try {
      // Request exact alarm permission
      final isPermissionGranted = await AlarmPermissionService().requestExactAlarmPermission();

      if (!isPermissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exact alarm permission is required to schedule notifications')),
          );
        }
        return;
      }

      // Save the notification to the database
      await DatabaseHelper().saveNotification(
        name,
        notificationDateTime,
        _selectedRepeatOption,
      );
      debugPrint('Notification saved to database');

      // Schedule the notification
      await _scheduleNotification(name, notificationDateTime, _selectedRepeatOption);
      debugPrint('Notification scheduled');

      // Navigate back to the previous screen
      if (mounted) {
        Navigator.of(context).pop();
      }
      debugPrint('Navigated back to the previous screen');
    } catch (e) {
      debugPrint('Error saving notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save notification')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Notification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Notification Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'No time selected'
                        : 'Selected Time: ${_selectedTime!.format(context)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text('Pick Time'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Repeat Option Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRepeatOption,
              items: _repeatOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRepeatOption = newValue;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveNotification,
                child: const Text('Save Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}