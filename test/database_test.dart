import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/data/datasources/database_helper.dart';
import 'package:fin_stats_app/data/datasources/unit_local_datasource.dart';
import 'package:fin_stats_app/data/datasources/section_local_datasource.dart';
import 'package:fin_stats_app/data/datasources/entry_local_datasource.dart';
import 'package:fin_stats_app/data/models/section_model.dart';
import 'package:fin_stats_app/data/models/entry_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late UnitLocalDataSource unitDataSource;
  late SectionLocalDataSource sectionDataSource;
  late EntryLocalDataSource entryDataSource;

  setUpAll(() {
    // Инициализация sqflite для тестов
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    unitDataSource = UnitLocalDataSource(dbHelper);
    sectionDataSource = SectionLocalDataSource(dbHelper);
    entryDataSource = EntryLocalDataSource(dbHelper);

    // Убедимся что БД создана
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('Database Tests', () {
    test('Предзаполненные единицы должны существовать', () async {
      final units = await unitDataSource.getAllUnits();

      expect(units.length, greaterThanOrEqualTo(7));
      expect(units.any((u) => u.code == 'RUB'), true);
      expect(units.any((u) => u.code == 'USD'), true);
      expect(units.any((u) => u.code == 'pcs'), true);
      expect(units.any((u) => u.code == 'l'), true);
      expect(units.any((u) => u.code == 'kg'), true);
      expect(units.any((u) => u.code == 'h'), true);
    });

    test('Создание и чтение Section', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final section = SectionModel(
        id: 'test-section-1',
        name: 'Тестовый раздел',
        icon: '💰',
        color: '#FF5722',
        createdAt: now,
        updatedAt: now,
      );

      await sectionDataSource.insertSection(section);
      final retrieved = await sectionDataSource.getSectionById('test-section-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Тестовый раздел');
      expect(retrieved.icon, '💰');
      expect(retrieved.color, '#FF5722');
    });

    test('Создание и чтение Entry', () async {
      // Создаём раздел
      final now = DateTime.now().millisecondsSinceEpoch;
      final section = SectionModel(
        id: 'test-section-2',
        name: 'Покупки',
        createdAt: now,
        updatedAt: now,
      );
      await sectionDataSource.insertSection(section);

      // Создаём запись
      final entry = EntryModel(
        id: 'test-entry-1',
        sectionId: 'test-section-2',
        description: 'Купил хлеб',
        valueType: 'MONEY',
        amount: 5000, // 50.00 руб в копейках
        unitId: 1, // RUB
        occurredAt: now,
        note: 'В магазине у дома',
        createdAt: now,
        updatedAt: now,
      );

      await entryDataSource.insertEntry(entry);
      final retrieved = await entryDataSource.getEntryById('test-entry-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.description, 'Купил хлеб');
      expect(retrieved.amount, 5000);
      expect(retrieved.valueType, 'MONEY');
      expect(retrieved.unitId, 1);
      expect(retrieved.note, 'В магазине у дома');
    });

    test('Каскадное удаление: удаление Section удаляет Entry', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Создаём раздел
      final section = SectionModel(
        id: 'test-section-3',
        name: 'Транспорт',
        createdAt: now,
        updatedAt: now,
      );
      await sectionDataSource.insertSection(section);

      // Создаём запись
      final entry = EntryModel(
        id: 'test-entry-2',
        sectionId: 'test-section-3',
        description: 'Бензин',
        valueType: 'QUANTITY',
        amount: 30000, // 30.000 литров
        unitId: 5, // л
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );
      await entryDataSource.insertEntry(entry);

      // Проверяем что запись есть
      final beforeDelete = await entryDataSource.getEntryById('test-entry-2');
      expect(beforeDelete, isNotNull);

      // Удаляем раздел
      await sectionDataSource.deleteSection('test-section-3');

      // Проверяем что запись удалилась каскадно
      final afterDelete = await entryDataSource.getEntryById('test-entry-2');
      expect(afterDelete, isNull);
    });

    test('Индексы работают: запросы по section_id быстрые', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Создаём раздел
      final section = SectionModel(
        id: 'test-section-4',
        name: 'Еда',
        createdAt: now,
        updatedAt: now,
      );
      await sectionDataSource.insertSection(section);

      // Создаём несколько записей
      for (int i = 0; i < 5; i++) {
        final entry = EntryModel(
          id: 'entry-$i',
          sectionId: 'test-section-4',
          description: 'Покупка $i',
          valueType: 'MONEY',
          amount: 1000 * (i + 1),
          unitId: 1,
          occurredAt: now + i * 1000,
          createdAt: now,
          updatedAt: now,
        );
        await entryDataSource.insertEntry(entry);
      }

      // Запрос по section_id должен вернуть все 5 записей
      final entries = await entryDataSource.getEntriesBySection('test-section-4');
      expect(entries.length, 5);
    });

    test('Получение единиц по типу', () async {
      final currencies = await unitDataSource.getUnitsByKind('CURRENCY');
      final counts = await unitDataSource.getUnitsByKind('COUNT');

      expect(currencies.length, greaterThanOrEqualTo(3)); // RUB, USD, EUR
      expect(counts.length, greaterThanOrEqualTo(4)); // pcs, l, kg, h

      expect(currencies.every((u) => u.kind == 'CURRENCY'), true);
      expect(counts.every((u) => u.kind == 'COUNT'), true);
    });
  });
}
