import '../entities/entry.dart';

/// Репозиторий для работы с записями
abstract class EntryRepository {
  /// Получить все записи раздела
  Future<List<Entry>> getEntriesBySection(String sectionId);

  /// Получить записи раздела за период
  Future<List<Entry>> getEntriesByPeriod({
    required String sectionId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Получить все записи за период (все разделы)
  Future<List<Entry>> getAllEntriesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Получить запись по id
  Future<Entry?> getEntryById(String id);

  /// Создать запись
  Future<void> createEntry(Entry entry);

  /// Обновить запись
  Future<void> updateEntry(Entry entry);

  /// Удалить запись
  Future<void> deleteEntry(String id);

  /// Получить количество записей в разделе
  Future<int> getEntryCountBySection(String sectionId);
}
