import '../models/section_model.dart';
import 'database_helper.dart';

/// Data source для работы с Sections в БД
class SectionLocalDataSource {
  final DatabaseHelper _dbHelper;

  SectionLocalDataSource(this._dbHelper);

  /// Получить все разделы
  Future<List<SectionModel>> getAllSections() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sections', orderBy: 'created_at DESC');
    return maps.map((map) => SectionModel.fromMap(map)).toList();
  }

  /// Получить раздел по id
  Future<SectionModel?> getSectionById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sections',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SectionModel.fromMap(maps.first);
  }

  /// Создать раздел
  Future<void> insertSection(SectionModel section) async {
    final db = await _dbHelper.database;
    await db.insert('sections', section.toMap());
  }

  /// Обновить раздел
  Future<void> updateSection(SectionModel section) async {
    final db = await _dbHelper.database;
    await db.update(
      'sections',
      section.toMap(),
      where: 'id = ?',
      whereArgs: [section.id],
    );
  }

  /// Удалить раздел (каскадно удалятся записи благодаря ON DELETE CASCADE)
  Future<void> deleteSection(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'sections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Stream всех разделов
  Stream<List<SectionModel>> watchAllSections() async* {
    while (true) {
      yield await getAllSections();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
