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

  /// Строка для показа пользователю в русской локали: пробел между тысячами
  /// и запятая как десятичный разделитель — «1 234,56». У количеств
  /// незначащие нули в дробной части убираются («1,25», «3»).
  /// Считается на целых числах, без погрешностей double.
  static String formatLocalized(int amount, ValueType type) {
    final scale = scaleFor(type);
    final decimals = decimalsFor(type);
    final abs = amount.abs();

    final whole = _groupThousands((abs ~/ scale).toString());
    var fraction = (abs % scale).toString().padLeft(decimals, '0');
    if (type == ValueType.quantity) {
      fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    }

    final sign = amount < 0 ? '\u2212' : '';
    return fraction.isEmpty ? '$sign$whole' : '$sign$whole,$fraction';
  }

  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
