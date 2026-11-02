import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/datasources/entry_local_datasource.dart';
import '../../data/datasources/section_local_datasource.dart';
import '../../data/datasources/unit_local_datasource.dart';
import '../../data/repositories/entry_repository_impl.dart';
import '../../data/repositories/section_repository_impl.dart';
import '../../data/repositories/unit_repository_impl.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/section_repository.dart';
import '../../domain/repositories/unit_repository.dart';
import '../../presentation/providers/entry_provider.dart';
import '../../presentation/providers/section_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/providers/statistics_provider.dart';
import '../../presentation/providers/unit_provider.dart';

final getIt = GetIt.instance;

/// Инициализация DI контейнера
Future<void> setupDependencies() async {
  // Настройки
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(getIt()),
  );

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

  // Repositories
  getIt.registerLazySingleton<UnitRepository>(
    () => UnitRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SectionRepository>(
    () => SectionRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<EntryRepository>(
    () => EntryRepositoryImpl(getIt()),
  );

  // Providers
  getIt.registerFactory<UnitProvider>(
    () => UnitProvider(getIt()),
  );
  getIt.registerFactory<SectionProvider>(
    () => SectionProvider(getIt()),
  );
  getIt.registerFactory<EntryProvider>(
    () => EntryProvider(getIt(), getIt<SettingsProvider>()),
  );
  getIt.registerFactory<StatisticsProvider>(
    () => StatisticsProvider(getIt(), getIt(), getIt<SettingsProvider>()),
  );

  // Инициализация БД (создание таблиц и предзаполнение)
  await getIt<DatabaseHelper>().database;
}
