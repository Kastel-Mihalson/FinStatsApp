import '../../core/utils/amount_utils.dart';
import '../../core/utils/csv_builder.dart';
import '../entities/entry.dart';
import '../repositories/entry_repository.dart';
import '../repositories/section_repository.dart';
import '../repositories/unit_repository.dart';

class ExportCsvUseCase {
  final SectionRepository _sectionRepository;
  final EntryRepository _entryRepository;
  final UnitRepository _unitRepository;

  ExportCsvUseCase(
    this._sectionRepository,
    this._entryRepository,
    this._unitRepository,
  );

  Future<String> exportSections() async {
    final sections = await _sectionRepository.getAllSections();
    return buildCsv(
      const ['Название', 'Иконка', 'Цвет'],
      sections
          .map((s) => [s.name, s.icon, _hexColor(s.color)])
          .toList(),
    );
  }

  Future<String> exportEntries() async {
    final sections = await _sectionRepository.getAllSections();
    final units = {
      for (final unit in await _unitRepository.getAllUnits()) unit.id: unit,
    };

    final rows = <List<String>>[];
    for (final section in sections) {
      final entries = await _entryRepository.getEntriesBySection(section.id);
      entries.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      for (final entry in entries) {
        rows.add([
          section.name,
          _formatDateTime(entry.occurredAt),
          entry.description,
          entry.valueType == ValueType.money ? 'Деньги' : 'Количество',
          AmountUtils.formatNumber(entry.amount, entry.valueType),
          units[entry.unitId]?.code ?? '',
          entry.note ?? '',
        ]);
      }
    }

    return buildCsv(
      const [
        'Раздел',
        'Дата',
        'Описание',
        'Тип',
        'Значение',
        'Единица',
        'Заметка',
      ],
      rows,
    );
  }

  String _formatDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  String _hexColor(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
