import '../../domain/entities/entry.dart';

/// Перевод значений записей между хранимым видом (целое число) и отображаемым.
///
/// Деньги хранятся в копейках (×100), количества — с точностью до 3 знаков
/// (×1000). Те же коэффициенты использует агрегация
/// (MoneyAggregationService / QuantityAggregationService).
class AmountUtils {
  static int scaleFor(ValueType type) => type == ValueType.money ? 100 : 1000;

  static int decimalsFor(ValueType type) => type == ValueType.money ? 2 : 3;

  /// Введённое пользователем число → хранимое целое.
  static int toStored(double value, ValueType type) =>
      (value * scaleFor(type)).round();

  /// Хранимое целое → число для показа/редактирования.
  static double toDisplay(int amount, ValueType type) =>
      amount / scaleFor(type);

  /// Строка вида «123.45» (деньги) или «1.250» (количества).
  static String formatNumber(int amount, ValueType type) =>
      toDisplay(amount, type).toStringAsFixed(decimalsFor(type));
}
