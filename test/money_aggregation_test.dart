import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/domain/entities/entry.dart';
import 'package:fin_stats_app/domain/entities/unit.dart';
import 'package:fin_stats_app/domain/usecases/money_aggregation_service.dart';

void main() {
  late List<Unit> units;

  setUp(() {
    units = [
      const Unit(id: 1, code: 'RUB', kind: UnitKind.currency, displayName: '₽'),
      const Unit(id: 2, code: 'USD', kind: UnitKind.currency, displayName: '\$'),
      const Unit(id: 3, code: 'EUR', kind: UnitKind.currency, displayName: '€'),
      const Unit(id: 4, code: 'pcs', kind: UnitKind.count, displayName: 'шт'),
    ];
  });

  group('MoneyAggregationService', () {
    test('aggregateByUnit суммирует деньги по валютам', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Покупка 1',
          valueType: ValueType.money,
          amount: 10000, // 100.00 руб
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Покупка 2',
          valueType: ValueType.money,
          amount: 5000, // 50.00 руб
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '3',
          sectionId: 's1',
          description: 'Покупка 3',
          valueType: ValueType.money,
          amount: 2000, // 20.00 USD
          unitId: 2,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = MoneyAggregationService.aggregateByUnit(
        entries: entries,
        units: units,
      );

      expect(result.length, 2); // RUB и USD
      expect(result[1]?.totalAmount, 15000); // 150.00 руб
      expect(result[1]?.amountInMainUnits, 150.0);
      expect(result[2]?.totalAmount, 2000); // 20.00 USD
      expect(result[2]?.amountInMainUnits, 20.0);
    });

    test('aggregateByUnit игнорирует количественные записи', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Деньги',
          valueType: ValueType.money,
          amount: 10000,
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Товар',
          valueType: ValueType.quantity,
          amount: 5000,
          unitId: 4, // шт (COUNT)
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = MoneyAggregationService.aggregateByUnit(
        entries: entries,
        units: units,
      );

      expect(result.length, 1); // только RUB
      expect(result[1]?.totalAmount, 10000);
    });

    test('aggregateByUnitId возвращает агрегацию для конкретной валюты', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Покупка 1',
          valueType: ValueType.money,
          amount: 10000,
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'Покупка 2',
          valueType: ValueType.money,
          amount: 5000,
          unitId: 2, // USD
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = MoneyAggregationService.aggregateByUnitId(
        entries: entries,
        unitId: 1,
        unit: units[0],
      );

      expect(result, isNotNull);
      expect(result!.totalAmount, 10000);
      expect(result.unitCode, 'RUB');
    });

    test('aggregateByUnitId возвращает null если нет записей', () {
      final result = MoneyAggregationService.aggregateByUnitId(
        entries: [],
        unitId: 1,
        unit: units[0],
      );

      expect(result, isNull);
    });

    test('getAggregationsList сортирует по убыванию суммы', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'RUB',
          valueType: ValueType.money,
          amount: 5000,
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '2',
          sectionId: 's1',
          description: 'USD',
          valueType: ValueType.money,
          amount: 10000,
          unitId: 2,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        Entry(
          id: '3',
          sectionId: 's1',
          description: 'EUR',
          valueType: ValueType.money,
          amount: 7000,
          unitId: 3,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final list = MoneyAggregationService.getAggregationsList(
        entries: entries,
        units: units,
      );

      expect(list.length, 3);
      expect(list[0].unitCode, 'USD'); // 10000
      expect(list[1].unitCode, 'EUR'); // 7000
      expect(list[2].unitCode, 'RUB'); // 5000
    });

    test('Точность денег: копейки корректно преобразуются', () {
      final now = DateTime.now();
      final entries = [
        Entry(
          id: '1',
          sectionId: 's1',
          description: 'Тест точности',
          valueType: ValueType.money,
          amount: 12345, // 123.45
          unitId: 1,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = MoneyAggregationService.aggregateByUnitId(
        entries: entries,
        unitId: 1,
        unit: units[0],
      );

      expect(result!.totalAmount, 12345);
      expect(result.amountInMainUnits, 123.45);
    });
  });
}
