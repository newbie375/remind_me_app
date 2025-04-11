import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../../domain/entities/theme_entity.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<void> initializeDatabase() async {
    if (_database != null) return; // Ensure this is called only once
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_settings.db');

    debugPrint('Initializing database at $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        debugPrint('Creating settings table');
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE,
            value TEXT
          )
        ''');
        await db.insert(
          'settings',
          {'key': 'isFirstLaunch', 'value': 'true'},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('Default isFirstLaunch value set to true');

        await db.execute('''
          CREATE TABLE theme_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isDarkMode INTEGER
          )
        ''');
        debugPrint('Database and table theme_settings created');

        await db.execute('''
          CREATE TABLE notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            repeat_option TEXT
          )
        ''');
        debugPrint('Table notifications created');
      },
    );
  }

  static const String _tableName = 'theme_settings';
  static const String _columnIsDarkMode = 'isDarkMode';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

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

  Future<void> saveNotification(String name, DateTime date, String repeatOption) async {
    final db = await database;
    await db.insert(
      'notifications',
      {
        'name': name,
        'date': date.toIso8601String(),
        'repeat_option': repeatOption,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('Notification saved: $name on $date with repeat: $repeatOption');
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'date ASC'); // Fetch notifications sorted by date
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_settings.db');

    try {
      await deleteDatabase(path);
      debugPrint('Database deleted successfully');
    } catch (e) {
      debugPrint('Error deleting database: $e');
    }
  }

  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final db = await database;
    debugPrint('Setting isFirstLaunch to $isFirstLaunch');
    await db.insert(
      'settings',
      {'key': 'isFirstLaunch', 'value': isFirstLaunch.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('isFirstLaunch updated in database');
  }

  Future<bool> isFirstLaunch() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['isFirstLaunch'],
    );

    debugPrint('isFirstLaunch query result: $result');

    if (result.isNotEmpty) {
      return result.first['value'] == 'true';
    }
    return true; // Default to true if no value is found
  }
}