/// Типы сортировки записей
enum SortType {
  /// По дате: новые первыми
  dateNewest,

  /// По дате: старые первыми
  dateOldest,

  /// По сумме: большие первыми
  amountHighest,

  /// По сумме: меньшие первыми
  amountLowest,
}

/// Расширение для удобного отображения типов сортировки
extension SortTypeExtension on SortType {
  String get displayName {
    switch (this) {
      case SortType.dateNewest:
        return 'По дате (новые)';
      case SortType.dateOldest:
        return 'По дате (старые)';
      case SortType.amountHighest:
        return 'По сумме (больше)';
      case SortType.amountLowest:
        return 'По сумме (меньше)';
    }
  }

  String get icon {
    switch (this) {
      case SortType.dateNewest:
        return '📅↓';
      case SortType.dateOldest:
        return '📅↑';
      case SortType.amountHighest:
        return '💰↓';
      case SortType.amountLowest:
        return '💰↑';
    }
  }
}
