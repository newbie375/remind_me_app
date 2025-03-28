import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,  // Set the current index
      onTap: onTap,  // Use the provided onTap callback
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),  // Home icon
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),  // Settings icon
          label: 'Settings',
        ),
      ],
    );
  }
}
