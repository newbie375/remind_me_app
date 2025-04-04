import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../../domain/entities/theme_entity.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  static const String _tableName = 'theme_settings';
  static const String _columnIsDarkMode = 'isDarkMode';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'settings.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
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
    final db = await database;
    debugPrint('Saving theme: isDarkMode = ${theme.isDarkMode}');
    await db.insert(
      _tableName,
      {_columnIsDarkMode: theme.isDarkMode ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('Theme saved successfully');
  }

  @override
  Future<ThemeEntity> getTheme() async {
    final db = await database;
    final result = await db.query(_tableName, limit: 1);
    debugPrint('Query result: $result');

    if (result.isNotEmpty) {
      debugPrint('Theme loaded: isDarkMode = ${result.first[_columnIsDarkMode]}');
      return ThemeEntity(isDarkMode: result.first[_columnIsDarkMode] == 1);
    }
    debugPrint('No theme found, defaulting to light mode');
    return const ThemeEntity(isDarkMode: false); // Default to light mode
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'settings.db');

    try {
      await deleteDatabase(path);
      debugPrint('Database deleted successfully');
    } catch (e) {
      debugPrint('Error deleting database: $e');
    }
  }
}