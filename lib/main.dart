import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/shared/custom_bottom_navigation.dart';

void main() {
  runApp(
    ProviderScope(
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
      home: const MainScreen(),
    );
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
