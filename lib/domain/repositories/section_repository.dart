import '../entities/section.dart';

/// Репозиторий для работы с разделами
abstract class SectionRepository {
  /// Получить все разделы
  Future<List<Section>> getAllSections();

  /// Получить раздел по id
  Future<Section?> getSectionById(String id);

  /// Создать раздел
  Future<void> createSection(Section section);

  /// Обновить раздел
  Future<void> updateSection(Section section);

  /// Удалить раздел (каскадно удалятся записи)
  Future<void> deleteSection(String id);

  /// Stream всех разделов для реактивного UI
  Stream<List<Section>> watchAllSections();
}
