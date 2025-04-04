import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_me_app/domain/use_cases/get_theme_use_case.dart';
import '../../domain/use_cases/save_theme_use_case.dart';
import '../../domain/entities/theme_entity.dart';
import '../../infrastructure/repositories/theme_repository_impl.dart';
import 'package:remind_me_app/config/theme/app_theme.dart';
import '../../domain/repositories/theme_repository.dart';

// Listado de colores inmutable
final colorListProvider = Provider((ref) => colorList);

// Un simple boolean
final isDarkmodeProvider = StateProvider((ref) => false);

// Un simple int
final selectedColorProvider = StateProvider((ref) => 0);

// Un objeto de tipo AppTheme (custom)
final themeNotifierProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  final repository = ThemeRepositoryImpl();
  return ThemeNotifier(repository);
});

// Controller o Notifier
class ThemeNotifier extends ChangeNotifier {
  final ThemeRepository _repository;
  bool _isDarkMode = false;

  ThemeNotifier(this._repository) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData getTheme() {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _repository.saveTheme(ThemeEntity(isDarkMode: _isDarkMode));
    debugPrint('Theme toggled to: ${_isDarkMode ? "Dark" : "Light"}');
  }

  Future<void> _loadTheme() async {
    final theme = await _repository.getTheme();
    _isDarkMode = theme.isDarkMode;
    notifyListeners();
    debugPrint('Loaded theme: ${_isDarkMode ? "Dark" : "Light"}');
  }
}
