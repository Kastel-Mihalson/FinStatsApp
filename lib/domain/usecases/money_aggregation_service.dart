import '../entities/entry.dart';
import '../entities/unit.dart';

/// Результат агрегации денежных записей
class MoneyAggregation {
  final int unitId;
  final String unitCode; // RUB, USD, EUR
  final String displayName; // ₽, $, €
  final int totalAmount; // в минимальных единицах (копейках)

  const MoneyAggregation({
    required this.unitId,
    required this.unitCode,
    required this.displayName,
    required this.totalAmount,
  });

  /// Преобразование в основные единицы (копейки → рубли)
  double get amountInMainUnits => totalAmount / 100.0;
}

/// Сервис для агрегации денежных записей
class MoneyAggregationService {
  /// Агрегировать денежные записи по валютам
  /// Возвращает Map: unitId → MoneyAggregation
  static Map<int, MoneyAggregation> aggregateByUnit({
    required List<Entry> entries,
    required List<Unit> units,
  }) {
    final result = <int, MoneyAggregation>{};

    // Фильтруем только денежные записи
    final moneyEntries = entries.where((e) => e.valueType == ValueType.money);

    // Создаем Map единиц для быстрого доступа
    final unitsMap = {for (var u in units) u.id: u};

    // Группируем по unitId и суммируем
    for (final entry in moneyEntries) {
      final unit = unitsMap[entry.unitId];
      if (unit == null || unit.kind != UnitKind.currency) continue;

      if (result.containsKey(entry.unitId)) {
        // Обновляем существующую агрегацию
        final current = result[entry.unitId]!;
        result[entry.unitId] = MoneyAggregation(
          unitId: current.unitId,
          unitCode: current.unitCode,
          displayName: current.displayName,
          totalAmount: current.totalAmount + entry.amount,
        );
      } else {
        // Создаем новую агрегацию
        result[entry.unitId] = MoneyAggregation(
          unitId: unit.id,
          unitCode: unit.code,
          displayName: unit.displayName,
          totalAmount: entry.amount,
        );
      }
    }

    return result;
  }

  /// Агрегировать денежные записи одной валюты
  static MoneyAggregation? aggregateByUnitId({
    required List<Entry> entries,
    required int unitId,
    required Unit unit,
  }) {
    if (unit.kind != UnitKind.currency) return null;

    final moneyEntries = entries.where(
      (e) => e.valueType == ValueType.money && e.unitId == unitId,
    );

    if (moneyEntries.isEmpty) return null;

    final totalAmount = moneyEntries.fold<int>(0, (sum, entry) => sum + entry.amount);

    return MoneyAggregation(
      unitId: unit.id,
      unitCode: unit.code,
      displayName: unit.displayName,
      totalAmount: totalAmount,
    );
  }

  /// Получить список всех агрегаций, отсортированных по сумме (убывание)
  static List<MoneyAggregation> getAggregationsList({
    required List<Entry> entries,
    required List<Unit> units,
  }) {
    final aggregations = aggregateByUnit(entries: entries, units: units);
    final list = aggregations.values.toList();
    list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }
}
