import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/unit_provider.dart';

/// Экран настроек
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final units = context.watch<UnitProvider>();

    var currencyText = settings.defaultCurrencyCode;
    for (final c in units.currencies) {
      if (c.code == settings.defaultCurrencyCode) {
        currencyText = '${c.code} (${c.displayName})';
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Валюта по умолчанию'),
            subtitle: Text(currencyText),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickCurrency(context),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week),
            title: const Text('Начало недели'),
            subtitle: Text(
              settings.weekStartsOnMonday ? 'Понедельник' : 'Воскресенье',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickWeekStart(context),
          ),
          const Divider(),
          // Эти пункты появятся на этапе 7 (экспорт CSV, PIN/биометрия).
          const ListTile(
            enabled: false,
            leading: Icon(Icons.lock_outline),
            title: Text('Блокировка приложения'),
            subtitle: Text('Появится позже'),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.file_download_outlined),
            title: Text('Экспорт данных (CSV)'),
            subtitle: Text('Появится позже'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final currencies = context.read<UnitProvider>().currencies;

    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Валюта по умолчанию'),
        children: [
          for (final c in currencies)
            ListTile(
              title: Text('${c.code} (${c.displayName})'),
              trailing: c.code == settings.defaultCurrencyCode
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(dialogContext, c.code),
            ),
        ],
      ),
    );

    if (code != null) await settings.setDefaultCurrency(code);
  }

  Future<void> _pickWeekStart(BuildContext context) async {
    final settings = context.read<SettingsProvider>();

    final monday = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Начало недели'),
        children: [
          ListTile(
            title: const Text('Понедельник'),
            trailing:
                settings.weekStartsOnMonday ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(dialogContext, true),
          ),
          ListTile(
            title: const Text('Воскресенье'),
            trailing:
                !settings.weekStartsOnMonday ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(dialogContext, false),
          ),
        ],
      ),
    );

    if (monday != null) await settings.setWeekStartsOnMonday(monday);
  }
}
