import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Настройки приложения (хранятся в SharedPreferences):
/// валюта по умолчанию и первый день недели.
class SettingsProvider with ChangeNotifier {
  static const String keyDefaultCurrency = 'default_currency';
  static const String keyWeekStartsOnMonday = 'week_starts_on_monday';

  final SharedPreferences _prefs;
  String _defaultCurrencyCode;
  bool _weekStartsOnMonday;

  SettingsProvider(SharedPreferences prefs)
      : _prefs = prefs,
        _defaultCurrencyCode =
            prefs.getString(keyDefaultCurrency) ?? AppConstants.defaultCurrency,
        _weekStartsOnMonday = prefs.getBool(keyWeekStartsOnMonday) ??
            AppConstants.defaultWeekStartsOnMonday;

  /// Код валюты по умолчанию (например, RUB).
  String get defaultCurrencyCode => _defaultCurrencyCode;

  /// true — неделя начинается с понедельника, false — с воскресенья.
  bool get weekStartsOnMonday => _weekStartsOnMonday;

  Future<void> setDefaultCurrency(String code) async {
    if (code == _defaultCurrencyCode) return;
    _defaultCurrencyCode = code;
    notifyListeners();
    try {
      await _prefs.setString(keyDefaultCurrency, code);
    } catch (e) {
      debugPrint('Не удалось сохранить валюту по умолчанию: $e');
    }
  }

  Future<void> setWeekStartsOnMonday(bool value) async {
    if (value == _weekStartsOnMonday) return;
    _weekStartsOnMonday = value;
    notifyListeners();
    try {
      await _prefs.setBool(keyWeekStartsOnMonday, value);
    } catch (e) {
      debugPrint('Не удалось сохранить начало недели: $e');
    }
  }
}
