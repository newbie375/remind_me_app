import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  static const String _tableName = 'theme';
  static const String _columnIsDarkMode = 'isDarkMode';

  Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'theme.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnIsDarkMode INTEGER
          )
        ''');
        debugPrint('Database and table $_tableName created');
      },
    );
  }

  @override
  Future<void> saveTheme(ThemeEntity theme) async {
    final db = await _getDatabase();
    await db.insert(
      _tableName,
      {_columnIsDarkMode: theme.isDarkMode ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ThemeEntity> getTheme() async {
    final db = await _getDatabase();
    final result = await db.query(_tableName, limit: 1);

    if (result.isNotEmpty) {
      return ThemeEntity(isDarkMode: result.first[_columnIsDarkMode] == 1);
    }
    return const ThemeEntity(isDarkMode: false); // Default to light mode
  }
}