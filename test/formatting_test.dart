import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/utils/amount_utils.dart';
import 'package:fin_stats_app/domain/entities/entry.dart';

void main() {
  const nbsp = ' ';

  group('AmountUtils.formatLocalized', () {
    test('деньги: запятая и пробелы между тысячами', () {
      expect(AmountUtils.formatLocalized(12345, ValueType.money), '123,45');
      expect(AmountUtils.formatLocalized(123456789, ValueType.money), '1${nbsp}234${nbsp}567,89');
      expect(AmountUtils.formatLocalized(100000, ValueType.money), '1${nbsp}000,00');
    });

    test('деньги: всегда 2 знака, в том числе для малых сумм', () {
      expect(AmountUtils.formatLocalized(5, ValueType.money), '0,05');
      expect(AmountUtils.formatLocalized(0, ValueType.money), '0,00');
      expect(AmountUtils.formatLocalized(100, ValueType.money), '1,00');
    });

    test('количества: лишние нули убираются', () {
      expect(AmountUtils.formatLocalized(1250, ValueType.quantity), '1,25');
      expect(AmountUtils.formatLocalized(3000, ValueType.quantity), '3');
      expect(AmountUtils.formatLocalized(1, ValueType.quantity), '0,001');
      expect(AmountUtils.formatLocalized(1234567, ValueType.quantity), '1${nbsp}234,567');
    });

    test('отрицательные значения', () {
      expect(AmountUtils.formatLocalized(-12345, ValueType.money), '−123,45');
    });
  });
}
