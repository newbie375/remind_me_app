import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_me_app/domain/use_cases/get_theme_use_case.dart';
import '../../domain/use_cases/save_theme_use_case.dart';
import '../../domain/entities/theme_entity.dart';
import '../../infrastructure/repositories/theme_repository_impl.dart';
import 'package:remind_me_app/config/theme/app_theme.dart';
// Listado de colores inmutable
final colorListProvider = Provider((ref) => colorList);

// Un simple boolean
final isDarkmodeProvider = StateProvider((ref) => false);

// Un simple int
final selectedColorProvider = StateProvider((ref) => 0);

// Un objeto de tipo AppTheme (custom)
final themeNotifierProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});

// Controller o Notifier
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode; // Getter for isDarkMode

  ThemeData getTheme() {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    // Save the theme to persistent storage (e.g., SQLite)
  }
}
