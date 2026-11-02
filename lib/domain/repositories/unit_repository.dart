import '../entities/unit.dart';

/// Репозиторий для работы с единицами измерения
abstract class UnitRepository {
  /// Получить все единицы
  Future<List<Unit>> getAllUnits();

  /// Получить единицу по id
  Future<Unit?> getUnitById(int id);

  /// Получить единицы по типу (валюты или количественные)
  Future<List<Unit>> getUnitsByKind(UnitKind kind);
}
