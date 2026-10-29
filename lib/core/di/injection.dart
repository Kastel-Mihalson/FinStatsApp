import 'package:get_it/get_it.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/datasources/entry_local_datasource.dart';
import '../../data/datasources/section_local_datasource.dart';
import '../../data/datasources/unit_local_datasource.dart';

final getIt = GetIt.instance;

/// Инициализация DI контейнера
Future<void> setupDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Data Sources
  getIt.registerLazySingleton<UnitLocalDataSource>(
    () => UnitLocalDataSource(getIt()),
  );
  getIt.registerLazySingleton<SectionLocalDataSource>(
    () => SectionLocalDataSource(getIt()),
  );
  getIt.registerLazySingleton<EntryLocalDataSource>(
    () => EntryLocalDataSource(getIt()),
  );

  // Инициализация БД (создание таблиц и предзаполнение)
  await getIt<DatabaseHelper>().database;
}
