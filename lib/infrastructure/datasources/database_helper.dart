import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

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
          CREATE TABLE theme_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isDarkMode INTEGER
          )
        ''');
      },
    );
  }

  Future<void> saveTheme(bool isDarkMode) async {
    final db = await database;
    await db.insert(
      'theme_settings',
      {'isDarkMode': isDarkMode ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getTheme() async {
    final db = await database;
    final result = await db.query('theme_settings', limit: 1);

    if (result.isNotEmpty) {
      return result.first['isDarkMode'] == 1;
    }
    return false; // Default to light mode if no theme is saved
  }
}