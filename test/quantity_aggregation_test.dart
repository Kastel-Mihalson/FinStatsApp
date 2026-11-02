import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/domain/entities/entry.dart';
import 'package:fin_stats_app/domain/entities/unit.dart';
import 'package:fin_stats_app/domain/usecases/quantity_aggregation_service.dart';

void main() {
  late List<Unit> units;

  setUp(() {
    units = [
      const Unit(id: 1, code: 'RUB', kind: UnitKind.currency, displayName: '₽'),
      const Unit(id: 4, code: 'pcs', kind: UnitKind.count, displayName: 'шт'),
      const Unit(id: 5, code: 'l', kind: UnitKind.count, displayName: 'л'),
      const Unit(id: 6, code: 'kg', kind: UnitKind.count, displayName: 'кг'),
    ];
  });

  group('QuantityAggregationService', () {
    test('aggregateByUnit суммирует количества по единицам', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Товар 1',
          valueType: ValueType.quantity,
          amount: 5000, // 5.000 шт
          unitId: 4,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Товар 2',
          valueType: ValueType.quantity,
          amount: 3000, // 3.000 шт
          unitId: 4,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '3',
          sectionId: 's1',
          description: 'Бензин',
          valueType: ValueType.quantity,
          amount: 30500, // 30.500 л
          unitId: 5,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = QuantityAggregationService.aggregateByUnit(
        entries: entries,
        units: units,
      );

      expect(result.length, 2); // шт и л
      expect(result[4]?.totalAmount, 8000); // 8.000 шт
      expect(result[4]?.amountInMainUnits, 8.0);
      expect(result[5]?.totalAmount, 30500); // 30.500 л
      expect(result[5]?.amountInMainUnits, 30.5);
    });

    test('aggregateByUnit игнорирует денежные записи', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Количество',
          valueType: ValueType.quantity,
          amount: 5000,
          unitId: 4,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Деньги',
          valueType: ValueType.money,
          amount: 10000,
          unitId: 1, // RUB (CURRENCY)
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = QuantityAggregationService.aggregateByUnit(
        entries: entries,
        units: units,
      );

      expect(result.length, 1); // только шт
      expect(result[4]?.totalAmount, 5000);
    });

    test('aggregateByUnitId возвращает агрегацию для конкретной единицы', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Литры',
          valueType: ValueType.quantity,
          amount: 20000, // 20.000 л
          unitId: 5,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Килограммы',
          valueType: ValueType.quantity,
          amount: 5000, // 5.000 кг
          unitId: 6,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = QuantityAggregationService.aggregateByUnitId(
        entries: entries,
        unitId: 5,
        unit: units[2], // л
      );

      expect(result, isNotNull);
      expect(result!.totalAmount, 20000);
      expect(result.unitCode, 'l');
      expect(result.displayName, 'л');
    });

    test('formatted возвращает строку с единицей измерения', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Бензин',
          valueType: ValueType.quantity,
          amount: 30750, // 30.750 л
          unitId: 5,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = QuantityAggregationService.aggregateByUnitId(
        entries: entries,
        unitId: 5,
        unit: units[2],
      );

      expect(result!.formatted, '30.750 л');
    });

    test('getAggregationsList сортирует по убыванию суммы', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Штуки',
          valueType: ValueType.quantity,
          amount: 5000,
          unitId: 4,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Литры',
          valueType: ValueType.quantity,
          amount: 30000,
          unitId: 5,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '3',
          sectionId: 's1',
          description: 'Килограммы',
          valueType: ValueType.quantity,
          amount: 15000,
          unitId: 6,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final list = QuantityAggregationService.getAggregationsList(
        entries: entries,
        units: units,
      );

      expect(list.length, 3);
      expect(list[0].unitCode, 'l'); // 30000
      expect(list[1].unitCode, 'kg'); // 15000
      expect(list[2].unitCode, 'pcs'); // 5000
    });

    test('Точность количеств: правильная работа с дробными значениями', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Тест точности',
          valueType: ValueType.quantity,
          amount: 12345, // 12.345
          unitId: 5,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = QuantityAggregationService.aggregateByUnitId(
        entries: entries,
        unitId: 5,
        unit: units[2],
      );

      expect(result!.totalAmount, 12345);
      expect(result.amountInMainUnits, 12.345);
    });
  });
}
