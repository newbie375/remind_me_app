import 'package:flutter/material.dart';
import 'package:remind_me_app/infrastructure/datasources/database_helper.dart';
import 'package:remind_me_app/presentation/screens/add_notificatons_screen.dart'; // Import the new screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Load notifications when the screen initializes
  }

  Future<void> _loadNotifications() async {
    final notifications = await DatabaseHelper().getNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                'There are no reminders created yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(notification['name']),
                    subtitle: Text(
                      'Date: ${notification['date']}\nRepeat: ${notification['repeat_option']}',
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingButton(onNotificationSaved: _loadNotifications),
    );
  }
}

class FloatingButton extends StatelessWidget {
  final VoidCallback onNotificationSaved;

  const FloatingButton({super.key, required this.onNotificationSaved});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Rounded edges for the card
      ),
      elevation: 4, // Adds shadow to the card
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensures the Card adjusts to content
          children: [
            const Text(
              'Create a reminder', // Text to display
              style: TextStyle(fontSize: 16), // Customize text style
            ),
            const SizedBox(width: 12), // Spacing between text and button
            FloatingActionButton(
              onPressed: () async {
                // Navigate to AddNotificationScreen
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddNotificationScreen(),
                  ),
                );
                onNotificationSaved(); // Reload notifications after saving
              },
              mini: true, // Smaller FAB to fit better in the card
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
