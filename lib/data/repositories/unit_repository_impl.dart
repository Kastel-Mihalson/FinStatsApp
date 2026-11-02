import '../../domain/entities/unit.dart';
import '../../domain/repositories/unit_repository.dart';
import '../datasources/unit_local_datasource.dart';
import '../mappers/unit_mapper.dart';

/// Реализация UnitRepository
class UnitRepositoryImpl implements UnitRepository {
  final UnitLocalDataSource _dataSource;

  UnitRepositoryImpl(this._dataSource);

  @override
  Future<List<Unit>> getAllUnits() async {
    final models = await _dataSource.getAllUnits();
    return UnitMapper.toEntityList(models);
  }

  @override
  Future<Unit?> getUnitById(int id) async {
    final model = await _dataSource.getUnitById(id);
    return model != null ? UnitMapper.toEntity(model) : null;
  }

  @override
  Future<List<Unit>> getUnitsByKind(UnitKind kind) async {
    final kindString = kind == UnitKind.currency ? 'CURRENCY' : 'COUNT';
    final models = await _dataSource.getUnitsByKind(kindString);
    return UnitMapper.toEntityList(models);
  }
}
