import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../core/constants/app_constants.dart';

/// Помощник для работы с БД
class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица Unit
    await db.execute('''
      CREATE TABLE units (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        kind TEXT NOT NULL,
        display_name TEXT NOT NULL
      )
    ''');

    // Таблица Section
    await db.execute('''
      CREATE TABLE sections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Таблица Entry
    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        section_id TEXT NOT NULL,
        description TEXT NOT NULL,
        value_type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        unit_id INTEGER NOT NULL,
        occurred_at INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (section_id) REFERENCES sections (id) ON DELETE CASCADE,
        FOREIGN KEY (unit_id) REFERENCES units (id)
      )
    ''');

    // Индексы для Entry (шаг 1.4)
    await db.execute('''
      CREATE INDEX idx_entry_section_id ON entries(section_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_entry_occurred_at ON entries(occurred_at)
    ''');

    // Предзаполнение Units (шаг 1.1)
    await _seedUnits(db);
  }

  Future<void> _seedUnits(Database db) async {
    final units = [
      {'id': 1, 'code': 'RUB', 'kind': 'CURRENCY', 'display_name': '₽'},
      {'id': 2, 'code': 'USD', 'kind': 'CURRENCY', 'display_name': '\$'},
      {'id': 3, 'code': 'EUR', 'kind': 'CURRENCY', 'display_name': '€'},
      {'id': 4, 'code': 'pcs', 'kind': 'COUNT', 'display_name': 'шт'},
      {'id': 5, 'code': 'l', 'kind': 'COUNT', 'display_name': 'л'},
      {'id': 6, 'code': 'kg', 'kind': 'COUNT', 'display_name': 'кг'},
      {'id': 7, 'code': 'h', 'kind': 'COUNT', 'display_name': 'ч'},
    ];

    for (final unit in units) {
      await db.insert('units', unit);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
