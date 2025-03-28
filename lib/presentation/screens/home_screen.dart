import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Reminders')),
      ),
      body: Center(
        // Ensures content is centered in the body
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the text vertically
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'There are no reminders created yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const FloatingButton(), // Use the custom FloatingButton
    );
  }
}

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});

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
              onPressed: () {
                // Handle button press
                debugPrint('Plus button pressed');
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
