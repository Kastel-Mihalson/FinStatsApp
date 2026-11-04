import 'package:flutter_test/flutter_test.dart';
import 'package:fin_stats_app/core/constants/app_constants.dart';
import 'package:fin_stats_app/data/datasources/database_helper.dart';
import 'package:fin_stats_app/data/datasources/entry_local_datasource.dart';
import 'package:fin_stats_app/data/datasources/section_local_datasource.dart';
import 'package:fin_stats_app/data/datasources/unit_local_datasource.dart';
import 'package:fin_stats_app/data/models/entry_model.dart';
import 'package:fin_stats_app/data/models/section_model.dart';
import 'package:fin_stats_app/data/repositories/entry_repository_impl.dart';
import 'package:fin_stats_app/data/repositories/section_repository_impl.dart';
import 'package:fin_stats_app/data/repositories/unit_repository_impl.dart';
import 'package:fin_stats_app/domain/usecases/export_csv_usecase.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SectionLocalDataSource sectionDataSource;
  late EntryLocalDataSource entryDataSource;
  late ExportCsvUseCase exporter;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbPath =
        join(await databaseFactoryFfi.getDatabasesPath(), AppConstants.dbName);
    await databaseFactoryFfi.deleteDatabase(dbPath);

    dbHelper = DatabaseHelper();
    sectionDataSource = SectionLocalDataSource(dbHelper);
    entryDataSource = EntryLocalDataSource(dbHelper);
    exporter = ExportCsvUseCase(
      SectionRepositoryImpl(sectionDataSource),
      EntryRepositoryImpl(entryDataSource),
      UnitRepositoryImpl(UnitLocalDataSource(dbHelper)),
    );
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('экспорт разделов и записей в CSV', () async {
    final occurred = DateTime(2026, 11, 4, 9, 30).millisecondsSinceEpoch;
    final later = DateTime(2026, 11, 4, 10, 15).millisecondsSinceEpoch;

    await sectionDataSource.insertSection(SectionModel(
      id: 'section-1',
      name: 'Продукты',
      icon: '🛒',
      color: 0xFF4CAF50,
      createdAt: occurred,
      updatedAt: occurred,
    ));
    await entryDataSource.insertEntry(EntryModel(
      id: 'entry-1',
      sectionId: 'section-1',
      description: 'Хлеб; батон',
      valueType: 'MONEY',
      amount: 12345,
      unitId: 1,
      occurredAt: occurred,
      note: null,
      createdAt: occurred,
      updatedAt: occurred,
    ));
    await entryDataSource.insertEntry(EntryModel(
      id: 'entry-2',
      sectionId: 'section-1',
      description: 'Молоко',
      valueType: 'QUANTITY',
      amount: 1500,
      unitId: 5,
      occurredAt: later,
      note: 'пастеризованное',
      createdAt: later,
      updatedAt: later,
    ));

    expect(
      await exporter.exportSections(),
      '\uFEFFНазвание;Иконка;Цвет\r\nПродукты;🛒;#4CAF50\r\n',
    );
    expect(
      await exporter.exportEntries(),
      '\uFEFFРаздел;Дата;Описание;Тип;Значение;Единица;Заметка\r\n'
      'Продукты;04.11.2026 09:30;"Хлеб; батон";Деньги;123.45;RUB;\r\n'
      'Продукты;04.11.2026 10:15;Молоко;Количество;1.500;l;пастеризованное\r\n',
    );
  });
}
