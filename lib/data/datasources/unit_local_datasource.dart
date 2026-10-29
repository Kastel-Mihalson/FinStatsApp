import '../models/unit_model.dart';
import 'database_helper.dart';

/// Data source для работы с Units в БД
class UnitLocalDataSource {
  final DatabaseHelper _dbHelper;

  UnitLocalDataSource(this._dbHelper);

  /// Получить все единицы
  Future<List<UnitModel>> getAllUnits() async {
    final db = await _dbHelper.database;
    final maps = await db.query('units', orderBy: 'id');
    return maps.map((map) => UnitModel.fromMap(map)).toList();
  }

  /// Получить единицу по id
  Future<UnitModel?> getUnitById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'units',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UnitModel.fromMap(maps.first);
  }

  /// Получить единицы по типу
  Future<List<UnitModel>> getUnitsByKind(String kind) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'units',
      where: 'kind = ?',
      whereArgs: [kind],
      orderBy: 'id',
    );
    return maps.map((map) => UnitModel.fromMap(map)).toList();
  }
}
