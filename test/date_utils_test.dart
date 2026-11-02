import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/utils/date_utils.dart';

void main() {
  group('DateTimeUtils - Периоды', () {
    test('getDayRange возвращает начало и конец дня', () {
      final date = DateTime(2026, 10, 29, 14, 30, 45);
      final range = DateTimeUtils.getDayRange(date);

      expect(range.start, DateTime(2026, 10, 29, 0, 0, 0));
      expect(range.end, DateTime(2026, 10, 29, 23, 59, 59, 999));
    });

    test('getWeekRange (понедельник первый) - середина недели', () {
      // Среда 29 октября 2026
      final date = DateTime(2026, 10, 29);
      final range = DateTimeUtils.getWeekRange(date, weekStartsOnMonday: true);

      // Неделя должна начинаться с понедельника 26 октября
      expect(range.start, DateTime(2026, 10, 26, 0, 0, 0));
      // И заканчиваться воскресеньем 1 ноября
      expect(range.end.day, 1);
      expect(range.end.month, 11);
    });

    test('getWeekRange (воскресенье первый) - середина недели', () {
      // Среда 29 октября 2026
      final date = DateTime(2026, 10, 29);
      final range = DateTimeUtils.getWeekRange(date, weekStartsOnMonday: false);

      // Неделя должна начинаться с воскресенья 25 октября
      expect(range.start, DateTime(2026, 10, 25, 0, 0, 0));
      // И заканчиваться субботой 31 октября
      expect(range.end.day, 31);
      expect(range.end.month, 10);
    });

    test('getWeekRange - граница месяца', () {
      // Первое число месяца, вторник
      final date = DateTime(2026, 12, 1);
      final range = DateTimeUtils.getWeekRange(date, weekStartsOnMonday: true);

      // Неделя начинается с понедельника 30 ноября
      expect(range.start.month, 11);
      expect(range.start.day, 30);
    });

    test('getMonthRange возвращает весь месяц', () {
      final date = DateTime(2026, 10, 15);
      final range = DateTimeUtils.getMonthRange(date);

      expect(range.start, DateTime(2026, 10, 1, 0, 0, 0));
      expect(range.end.day, 31); // октябрь 31 день
      expect(range.end.month, 10);
    });

    test('getMonthRange - февраль високосного года', () {
      final date = DateTime(2024, 2, 15); // 2024 - високосный
      final range = DateTimeUtils.getMonthRange(date);

      expect(range.start, DateTime(2024, 2, 1, 0, 0, 0));
      expect(range.end.day, 29); // 29 дней в феврале
    });

    test('getMonthRange - февраль обычного года', () {
      final date = DateTime(2026, 2, 15);
      final range = DateTimeUtils.getMonthRange(date);

      expect(range.start, DateTime(2026, 2, 1, 0, 0, 0));
      expect(range.end.day, 28); // 28 дней в феврале
    });

    test('getYearRange возвращает весь год', () {
      final date = DateTime(2026, 6, 15);
      final range = DateTimeUtils.getYearRange(date);

      expect(range.start, DateTime(2026, 1, 1, 0, 0, 0));
      expect(range.end, DateTime(2026, 12, 31, 23, 59, 59, 999));
    });

    test('getPeriodRange работает для всех типов', () {
      final date = DateTime(2026, 10, 29);

      final dayRange = DateTimeUtils.getPeriodRange(date, PeriodType.day);
      expect(dayRange.start.day, 29);

      final weekRange = DateTimeUtils.getPeriodRange(date, PeriodType.week);
      expect(weekRange.start.day, 26); // понедельник

      final monthRange = DateTimeUtils.getPeriodRange(date, PeriodType.month);
      expect(monthRange.start.day, 1);

      final yearRange = DateTimeUtils.getPeriodRange(date, PeriodType.year);
      expect(yearRange.start.month, 1);

      final allRange = DateTimeUtils.getPeriodRange(date, PeriodType.all);
      expect(allRange.start.year, 2000);
    });

    test('DateTimeRange.contains проверяет вхождение даты', () {
      final range = DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 31, 23, 59, 59),
      );

      expect(range.contains(DateTime(2026, 10, 15)), true);
      expect(range.contains(DateTime(2026, 10, 1)), true); // граница
      expect(range.contains(DateTime(2026, 9, 30)), false);
      expect(range.contains(DateTime(2026, 11, 1)), false);
    });

    test('formatDate форматирует дату корректно', () {
      final date = DateTime(2026, 10, 29, 14, 5);

      expect(DateTimeUtils.formatDate(date), '29.10.2026');
      expect(
        DateTimeUtils.formatDate(date, format: 'dd.MM.yyyy HH:mm'),
        '29.10.2026 14:05',
      );
    });
  });
}
