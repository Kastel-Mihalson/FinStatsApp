import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/utils/amount_utils.dart';
import 'package:fin_stats_app/core/utils/date_utils.dart';
import 'package:fin_stats_app/domain/entities/entry.dart';

void main() {
  group('DateTimeUtils.shiftDate', () {
    test('день и неделя', () {
      final d = DateTime(2026, 11, 2, 15, 30);
      expect(DateTimeUtils.shiftDate(d, PeriodType.day, -1), DateTime(2026, 11, 1));
      expect(DateTimeUtils.shiftDate(d, PeriodType.day, 1), DateTime(2026, 11, 3));
      expect(DateTimeUtils.shiftDate(d, PeriodType.week, -1), DateTime(2026, 10, 26));
      expect(DateTimeUtils.shiftDate(d, PeriodType.week, 1), DateTime(2026, 11, 9));
    });

    test('день: переход через границу месяца и года', () {
      expect(
        DateTimeUtils.shiftDate(DateTime(2026, 1, 1), PeriodType.day, -1),
        DateTime(2025, 12, 31),
      );
      expect(
        DateTimeUtils.shiftDate(DateTime(2026, 2, 28), PeriodType.day, 1),
        DateTime(2026, 3, 1),
      );
    });

    test('месяц: 31 января + 1 месяц = февраль, а не март', () {
      final shifted = DateTimeUtils.shiftDate(DateTime(2026, 1, 31), PeriodType.month, 1);
      expect(shifted.year, 2026);
      expect(shifted.month, 2);
    });

    test('месяц и год: переход через границу года', () {
      final back = DateTimeUtils.shiftDate(DateTime(2026, 1, 15), PeriodType.month, -1);
      expect((back.year, back.month), (2025, 12));
      final fwd = DateTimeUtils.shiftDate(DateTime(2026, 12, 15), PeriodType.month, 1);
      expect((fwd.year, fwd.month), (2027, 1));
      expect(DateTimeUtils.shiftDate(DateTime(2026, 5, 5), PeriodType.year, -1).year, 2025);
    });

    test('«Всё время» не сдвигается', () {
      final d = DateTime(2026, 11, 2);
      expect(DateTimeUtils.shiftDate(d, PeriodType.all, 5), d);
    });
  });

  group('DateTimeUtils.formatPeriodLabel', () {
    final d = DateTime(2026, 11, 2); // понедельник

    test('день, месяц, год, всё время', () {
      expect(DateTimeUtils.formatPeriodLabel(d, PeriodType.day), '02.11.2026');
      expect(DateTimeUtils.formatPeriodLabel(d, PeriodType.month), 'Ноябрь 2026');
      expect(DateTimeUtils.formatPeriodLabel(d, PeriodType.year), '2026');
      expect(DateTimeUtils.formatPeriodLabel(d, PeriodType.all), 'Всё время');
    });

    test('неделя зависит от начала недели', () {
      expect(
        DateTimeUtils.formatPeriodLabel(d, PeriodType.week),
        '02.11.2026 – 08.11.2026',
      );
      expect(
        DateTimeUtils.formatPeriodLabel(d, PeriodType.week, weekStartsOnMonday: false),
        '01.11.2026 – 07.11.2026',
      );
    });
  });

  group('AmountUtils', () {
    test('деньги: копейки, 2 знака', () {
      expect(AmountUtils.toStored(123.45, ValueType.money), 12345);
      expect(AmountUtils.formatNumber(12345, ValueType.money), '123.45');
    });

    test('количества: 3 знака, как в QuantityAggregationService', () {
      expect(AmountUtils.toStored(1.25, ValueType.quantity), 1250);
      expect(AmountUtils.formatNumber(1250, ValueType.quantity), '1.250');
    });

    test('округление без потери копейки (0.29 * 100)', () {
      expect(AmountUtils.toStored(0.29, ValueType.money), 29);
      expect(AmountUtils.toStored(19.99, ValueType.money), 1999);
    });
  });
}
