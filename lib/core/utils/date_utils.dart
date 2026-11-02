/// Тип периода для группировки записей
enum PeriodType {
  day,
  week,
  month,
  year,
  all,
}

/// Утилиты для работы с датами и периодами
class DateTimeUtils {
  /// Получить начало и конец дня
  static DateTimeRange getDayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  /// Получить начало и конец недели
  /// [weekStartsOnMonday] — если true, неделя начинается с понедельника, иначе с воскресенья
  static DateTimeRange getWeekRange(DateTime date, {bool weekStartsOnMonday = true}) {
    final targetWeekday = weekStartsOnMonday ? DateTime.monday : DateTime.sunday;

    // Найти первый день недели
    int daysToSubtract = (date.weekday - targetWeekday + 7) % 7;
    final start = DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));

    // Последний день недели (6 дней после начала)
    final end = DateTime(start.year, start.month, start.day + 6, 23, 59, 59, 999);

    return DateTimeRange(start: start, end: end);
  }

  /// Получить начало и конец месяца
  static DateTimeRange getMonthRange(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  /// Получить начало и конец года
  static DateTimeRange getYearRange(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year, 12, 31, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  /// Получить диапазон по типу периода
  static DateTimeRange getPeriodRange(DateTime date, PeriodType periodType, {bool weekStartsOnMonday = true}) {
    switch (periodType) {
      case PeriodType.day:
        return getDayRange(date);
      case PeriodType.week:
        return getWeekRange(date, weekStartsOnMonday: weekStartsOnMonday);
      case PeriodType.month:
        return getMonthRange(date);
      case PeriodType.year:
        return getYearRange(date);
      case PeriodType.all:
        // Для "все время" используем очень широкий диапазон
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 12, 31, 23, 59, 59, 999),
        );
    }
  }

  /// Форматирование даты в строку (локаль RU)
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    // Базовое форматирование без intl для простоты
    if (format == 'dd.MM.yyyy') {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } else if (format == 'dd.MM.yyyy HH:mm') {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return date.toString();
  }
}

/// Диапазон дат (аналог DateTimeRange из Flutter, но без зависимости от Flutter)
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
           date.isAtSameMomentAs(start) ||
           date.isAtSameMomentAs(end);
  }
}
