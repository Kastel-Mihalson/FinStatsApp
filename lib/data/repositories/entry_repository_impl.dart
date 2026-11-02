import '../../domain/entities/entry.dart';
import '../../domain/repositories/entry_repository.dart';
import '../datasources/entry_local_datasource.dart';
import '../mappers/entry_mapper.dart';

/// Реализация EntryRepository
class EntryRepositoryImpl implements EntryRepository {
  final EntryLocalDataSource _dataSource;

  EntryRepositoryImpl(this._dataSource);

  @override
  Future<List<Entry>> getEntriesBySection(String sectionId) async {
    final models = await _dataSource.getEntriesBySection(sectionId);
    return EntryMapper.toEntityList(models);
  }

  @override
  Future<List<Entry>> getEntriesByPeriod({
    required String sectionId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _dataSource.getEntriesByPeriod(
      sectionId: sectionId,
      startTimestamp: startDate.millisecondsSinceEpoch,
      endTimestamp: endDate.millisecondsSinceEpoch,
    );
    return EntryMapper.toEntityList(models);
  }

  @override
  Future<List<Entry>> getAllEntriesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _dataSource.getAllEntriesByPeriod(
      startTimestamp: startDate.millisecondsSinceEpoch,
      endTimestamp: endDate.millisecondsSinceEpoch,
    );
    return EntryMapper.toEntityList(models);
  }

  @override
  Future<Entry?> getEntryById(String id) async {
    final model = await _dataSource.getEntryById(id);
    return model != null ? EntryMapper.toEntity(model) : null;
  }

  @override
  Future<void> createEntry(Entry entry) async {
    final model = EntryMapper.toModel(entry);
    await _dataSource.insertEntry(model);
  }

  @override
  Future<void> updateEntry(Entry entry) async {
    final model = EntryMapper.toModel(entry);
    await _dataSource.updateEntry(model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _dataSource.deleteEntry(id);
  }

  @override
  Future<int> getEntryCountBySection(String sectionId) async {
    return await _dataSource.getEntryCountBySection(sectionId);
  }
}
