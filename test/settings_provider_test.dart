import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_stats_app/core/utils/date_utils.dart';
import 'package:fin_stats_app/presentation/providers/entry_provider.dart';
import 'package:fin_stats_app/presentation/providers/settings_provider.dart';

import 'entry_provider_test.dart' show FakeEntryRepository;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsProvider> create([Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    return SettingsProvider(await SharedPreferences.getInstance());
  }

  group('SettingsProvider', () {
    test('значения по умолчанию: RUB, неделя с понедельника', () async {
      final settings = await create();

      expect(settings.defaultCurrencyCode, 'RUB');
      expect(settings.weekStartsOnMonday, isTrue);
    });

    test('читает сохранённые значения', () async {
      final settings = await create({
        SettingsProvider.keyDefaultCurrency: 'USD',
        SettingsProvider.keyWeekStartsOnMonday: false,
      });

      expect(settings.defaultCurrencyCode, 'USD');
      expect(settings.weekStartsOnMonday, isFalse);
    });

    test('сохраняет изменения и уведомляет слушателей', () async {
      final settings = await create();
      var notified = 0;
      settings.addListener(() => notified++);

      await settings.setDefaultCurrency('EUR');
      await settings.setWeekStartsOnMonday(false);
      await settings.setWeekStartsOnMonday(false); // без изменений

      expect(notified, 2);

      // Новый экземпляр на тех же prefs видит сохранённые значения.
      final reloaded = SettingsProvider(await SharedPreferences.getInstance());
      expect(reloaded.defaultCurrencyCode, 'EUR');
      expect(reloaded.weekStartsOnMonday, isFalse);
    });
  });

  group('EntryProvider + настройки', () {
    test('начало недели из настроек влияет на период «Неделя»', () async {
      final settings = await create();
      final provider = EntryProvider(FakeEntryRepository(), settings);
      await provider.openSection('s1');
      await provider.setPeriod(PeriodType.week);

      final mondayLabel = provider.periodLabel;
      expect(provider.weekStartsOnMonday, isTrue);

      await settings.setWeekStartsOnMonday(false);

      expect(provider.weekStartsOnMonday, isFalse);
      expect(provider.periodLabel, isNot(mondayLabel));
    });
  });
}
