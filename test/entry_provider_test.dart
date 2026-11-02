import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/enums/sort_type.dart';
import 'package:fin_stats_app/core/utils/date_utils.dart';
import 'package:fin_stats_app/domain/entities/entry.dart';
import 'package:fin_stats_app/domain/repositories/entry_repository.dart';
import 'package:fin_stats_app/presentation/providers/entry_provider.dart';

/// Простая in-memory реализация репозитория для тестов провайдера.
class FakeEntryRepository implements EntryRepository {
  final List<Entry> items = [];

  List<Entry> _inRange(String? sectionId, DateTime? start, DateTime? end) {
    return items.where((e) {
      if (sectionId != null && e.sectionId != sectionId) return false;
      if (start != null && e.occurredAt.isBefore(start)) return false;
      if (end != null && e.occurredAt.isAfter(end)) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Entry>> getEntriesBySection(String sectionId) async =>
      _inRange(sectionId, null, null);

  @override
  Future<List<Entry>> getEntriesByPeriod({
    required String sectionId,
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      _inRange(sectionId, startDate, endDate);

  @override
  Future<List<Entry>> getAllEntriesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      _inRange(null, startDate, endDate);

  @override
  Future<Entry?> getEntryById(String id) async {
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<void> createEntry(Entry entry) async => items.add(entry);

  @override
  Future<void> updateEntry(Entry entry) async {
    final i = items.indexWhere((e) => e.id == entry.id);
    if (i >= 0) items[i] = entry;
  }

  @override
  Future<void> deleteEntry(String id) async =>
      items.removeWhere((e) => e.id == id);

  @override
  Future<int> getEntryCountBySection(String sectionId) async =>
      items.where((e) => e.sectionId == sectionId).length;
}

Entry makeEntry(
  String id, {
  required DateTime at,
  int amount = 100,
  String sectionId = 's1',
}) {
  return Entry(
    id: id,
    sectionId: sectionId,
    description: id,
    valueType: ValueType.money,
    amount: amount,
    unitId: 1,
    occurredAt: at,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  late FakeEntryRepository repo;
  late EntryProvider provider;
  late DateTime today; // сегодня, 12:00
  late DateTime yesterday;
  late DateTime longAgo; // 40 дней назад — гарантированно другой месяц

  List<String> ids() => provider.entries.map((e) => e.id).toList();

  setUp(() {
    final n = DateTime.now();
    today = DateTime(n.year, n.month, n.day, 12);
    yesterday = DateTime(n.year, n.month, n.day - 1, 12);
    longAgo = DateTime(n.year, n.month, n.day - 40, 12);

    repo = FakeEntryRepository()
      ..items.addAll([
        makeEntry('today', at: today, amount: 500),
        makeEntry('yesterday', at: yesterday, amount: 900),
        makeEntry('old', at: longAgo, amount: 100),
        makeEntry('other', at: today, amount: 777, sectionId: 's2'),
      ]);
    provider = EntryProvider(repo);
  });

  group('EntryProvider - загрузка и сортировка', () {
    test('openSection: все записи раздела, новые первыми', () async {
      await provider.openSection('s1');

      expect(provider.period, PeriodType.all);
      expect(provider.sort, SortType.dateNewest);
      expect(ids(), ['today', 'yesterday', 'old']);
    });

    test('сортировка по дате (старые первыми)', () async {
      await provider.openSection('s1');
      provider.setSort(SortType.dateOldest);

      expect(ids(), ['old', 'yesterday', 'today']);
    });

    test('сортировка по значению (по убыванию и по возрастанию)', () async {
      await provider.openSection('s1');

      provider.setSort(SortType.amountHighest);
      expect(ids(), ['yesterday', 'today', 'old']);

      provider.setSort(SortType.amountLowest);
      expect(ids(), ['old', 'today', 'yesterday']);
    });

    test('равные значения упорядочиваются по дате (новые первыми)', () async {
      repo.items
        ..clear()
        ..addAll([
          makeEntry('a', at: yesterday, amount: 100),
          makeEntry('b', at: today, amount: 100),
        ]);
      await provider.openSection('s1');
      provider.setSort(SortType.amountHighest);

      expect(ids(), ['b', 'a']);
    });
  });

  group('EntryProvider - периоды', () {
    test('день: только сегодняшние записи', () async {
      await provider.openSection('s1');
      await provider.setPeriod(PeriodType.day);

      expect(ids(), ['today']);
    });

    test('день: переход назад и вперёд', () async {
      await provider.openSection('s1');
      await provider.setPeriod(PeriodType.day);

      await provider.previousPeriod();
      expect(ids(), ['yesterday']);

      await provider.nextPeriod();
      expect(ids(), ['today']);
    });

    test('месяц исключает запись 40-дневной давности, «Всё» возвращает', () async {
      await provider.openSection('s1');

      await provider.setPeriod(PeriodType.month);
      expect(ids().contains('old'), isFalse);
      expect(ids().contains('today'), isTrue);

      await provider.setPeriod(PeriodType.all);
      expect(ids().contains('old'), isTrue);
    });

    test('для «Всё время» листание периодов недоступно', () async {
      await provider.openSection('s1');

      expect(provider.canNavigatePeriod, isFalse);
      await provider.nextPeriod();
      expect(provider.period, PeriodType.all);
      expect(ids(), ['today', 'yesterday', 'old']);
    });

    test('записи другого раздела не попадают в список', () async {
      await provider.openSection('s1');
      expect(ids().contains('other'), isFalse);

      await provider.openSection('s2');
      expect(ids(), ['other']);
    });

    test('openSection сбрасывает период и сортировку', () async {
      await provider.openSection('s1');
      await provider.setPeriod(PeriodType.day);
      provider.setSort(SortType.amountLowest);

      await provider.openSection('s1');

      expect(provider.period, PeriodType.all);
      expect(provider.sort, SortType.dateNewest);
    });
  });

  group('EntryProvider - изменения данных', () {
    test('создание записи сохраняет выбранный период и сортировку', () async {
      await provider.openSection('s1');
      await provider.setPeriod(PeriodType.day);
      provider.setSort(SortType.amountHighest);

      await provider.createEntry(makeEntry('new', at: today, amount: 9999));
      expect(provider.period, PeriodType.day);
      expect(ids(), ['new', 'today']);

      // запись вне выбранного периода в список не попадает
      await provider.createEntry(makeEntry('ancient', at: longAgo));
      expect(ids().contains('ancient'), isFalse);
    });

    test('удаление записи обновляет список', () async {
      await provider.openSection('s1');
      await provider.deleteEntry('yesterday');

      expect(ids(), ['today', 'old']);
    });
  });
}
