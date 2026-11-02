import '../../domain/entities/section.dart';
import '../../domain/repositories/section_repository.dart';
import '../datasources/section_local_datasource.dart';
import '../mappers/section_mapper.dart';

/// Реализация SectionRepository
class SectionRepositoryImpl implements SectionRepository {
  final SectionLocalDataSource _dataSource;

  SectionRepositoryImpl(this._dataSource);

  @override
  Future<List<Section>> getAllSections() async {
    final models = await _dataSource.getAllSections();
    return SectionMapper.toEntityList(models);
  }

  @override
  Future<Section?> getSectionById(String id) async {
    final model = await _dataSource.getSectionById(id);
    return model != null ? SectionMapper.toEntity(model) : null;
  }

  @override
  Future<void> createSection(Section section) async {
    final model = SectionMapper.toModel(section);
    await _dataSource.insertSection(model);
  }

  @override
  Future<void> updateSection(Section section) async {
    final model = SectionMapper.toModel(section);
    await _dataSource.updateSection(model);
  }

  @override
  Future<void> deleteSection(String id) async {
    await _dataSource.deleteSection(id);
  }

  @override
  Stream<List<Section>> watchAllSections() {
    return _dataSource.watchAllSections().map((models) {
      return SectionMapper.toEntityList(models);
    });
  }
}
