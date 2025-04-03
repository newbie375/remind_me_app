import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_me_app/presentation/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    String selectedLanguage = 'English'; // Default language

    return Scaffold(
      //appBar: AppBar(
        //title: const Text('Settings'),
        //centerTitle: true,
      //),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dark mode toggle setting using ListTile with Switch
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  ref.read(themeNotifierProvider.notifier).toggleTheme();
                },
                activeColor: Colors.blue, // Customize the active color
                inactiveThumbColor: Colors.grey, // Customize the inactive thumb color
                inactiveTrackColor: Colors.grey.shade300, // Customize the inactive track color
              ),
            ),
            // Language change setting using ListTile
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the padding
              title: const Text('Change Language'),
              trailing: DropdownButton<String>(
                value: selectedLanguage, // Use the selectedLanguage variable
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'Spanish',
                    child: Text('Español'),
                  ),
                  DropdownMenuItem(
                    value: 'Japanese',
                    child: Text('日本語'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedLanguage = newValue; // Update the selected language
                    debugPrint('Selected Language: $newValue');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
