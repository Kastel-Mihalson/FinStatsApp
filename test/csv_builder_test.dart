import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/utils/csv_builder.dart';

void main() {
  test('добавляет BOM и CRLF между строками', () {
    final csv = buildCsv(const ['A', 'B'], const [['1', '2']]);
    expect(csv, '\uFEFFA;B\r\n1;2\r\n');
  });

  test('экранирует значения с разделителем, кавычками и переносами', () {
    final csv = buildCsv(const ['Заметка'], const [
      ['купил; 2 шт'],
      ['он сказал "да"'],
      ['строка1\nстрока2'],
    ]);
    expect(
      csv,
      '\uFEFFЗаметка\r\n'
      '"купил; 2 шт"\r\n'
      '"он сказал ""да"""\r\n'
      '"строка1\nстрока2"\r\n',
    );
  });
}
