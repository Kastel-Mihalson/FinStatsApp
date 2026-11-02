import '../entities/entry.dart';
import '../entities/unit.dart';

/// Результат агрегации количественных записей
class QuantityAggregation {
  final int unitId;
  final String unitCode; // pcs, l, kg, h
  final String displayName; // шт, л, кг, ч
  final int totalAmount; // в минимальных единицах (с фиксированной точностью)

  const QuantityAggregation({
    required this.unitId,
    required this.unitCode,
    required this.displayName,
    required this.totalAmount,
  });

  /// Преобразование в основные единицы (с точностью 3 знака)
  double get amountInMainUnits => totalAmount / 1000.0;

  /// Форматированная строка с единицей измерения
  String get formatted => '${amountInMainUnits.toStringAsFixed(3)} $displayName';
}

/// Сервис для агрегации количественных записей
class QuantityAggregationService {
  /// Агрегировать количественные записи по единицам измерения
  /// Возвращает Map: unitId → QuantityAggregation
  static Map<int, QuantityAggregation> aggregateByUnit({
    required List<Entry> entries,
    required List<Unit> units,
  }) {
    final result = <int, QuantityAggregation>{};

    // Фильтруем только количественные записи
    final quantityEntries = entries.where((e) => e.valueType == ValueType.quantity);

    // Создаем Map единиц для быстрого доступа
    final unitsMap = {for (var u in units) u.id: u};

    // Группируем по unitId и суммируем
    for (final entry in quantityEntries) {
      final unit = unitsMap[entry.unitId];
      if (unit == null || unit.kind != UnitKind.count) continue;

      if (result.containsKey(entry.unitId)) {
        // Обновляем существующую агрегацию
        final current = result[entry.unitId]!;
        result[entry.unitId] = QuantityAggregation(
          unitId: current.unitId,
          unitCode: current.unitCode,
          displayName: current.displayName,
          totalAmount: current.totalAmount + entry.amount,
        );
      } else {
        // Создаем новую агрегацию
        result[entry.unitId] = QuantityAggregation(
          unitId: unit.id,
          unitCode: unit.code,
          displayName: unit.displayName,
          totalAmount: entry.amount,
        );
      }
    }

    return result;
  }

  /// Агрегировать количественные записи одной единицы
  static QuantityAggregation? aggregateByUnitId({
    required List<Entry> entries,
    required int unitId,
    required Unit unit,
  }) {
    if (unit.kind != UnitKind.count) return null;

    final quantityEntries = entries.where(
      (e) => e.valueType == ValueType.quantity && e.unitId == unitId,
    );

    if (quantityEntries.isEmpty) return null;

    final totalAmount = quantityEntries.fold<int>(0, (sum, entry) => sum + entry.amount);

    return QuantityAggregation(
      unitId: unit.id,
      unitCode: unit.code,
      displayName: unit.displayName,
      totalAmount: totalAmount,
    );
  }

  /// Получить список всех агрегаций, отсортированных по сумме (убывание)
  static List<QuantityAggregation> getAggregationsList({
    required List<Entry> entries,
    required List<Unit> units,
  }) {
    final aggregations = aggregateByUnit(entries: entries, units: units);
    final list = aggregations.values.toList();
    list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }
}
