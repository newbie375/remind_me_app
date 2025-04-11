import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:remind_me_app/infrastructure/datasources/database_helper.dart';
import 'package:remind_me_app/infrastructure/services/alarm_permission_service.dart';
import 'package:remind_me_app/presentation/screens/notification_permission_screen.dart';
import 'package:remind_me_app/presentation/screens/home_screen.dart';
import 'package:remind_me_app/presentation/screens/settings_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/widgets/shared/custom_bottom_navigation.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone package
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Set your local timezone

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme.getTheme(),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await DatabaseHelper().isFirstLaunch();
    if (isFirstLaunch) {
      _showPermissionDialog();
    }
    setState(() {
      _isFirstLaunch = false;
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Notification Permission'),
          content: const Text(
              'This app requires notification permissions to send reminders. Please grant permission.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog

                // Request notification permission
                final isPermissionGranted =
                    await AlarmPermissionService().requestExactAlarmPermission();

                if (!isPermissionGranted) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Exact alarm permission is required to schedule notifications.'),
                      ),
                    );
                  }
                } else {
                  // Mark first launch as complete
                  await DatabaseHelper().setFirstLaunch(false);
                }
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static const List<Widget> _screens = <Widget>[
    HomePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index < 0 || index >= _screens.length) return; // Prevent invalid index
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider); // Use ref.watch to listen to changes

    // Titles for the AppBar based on the selected index
    final appBarTitles = ['Reminders', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_selectedIndex]), // Dynamically set the title
        centerTitle: true, // Center the title text
        actions: [
          IconButton(
            icon: Icon(themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeNotifier.toggleTheme(); // Toggle the theme
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
