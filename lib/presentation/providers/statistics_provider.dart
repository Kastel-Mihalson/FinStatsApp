import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/entry.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/unit_repository.dart';
import '../../domain/usecases/money_aggregation_service.dart';
import '../../domain/usecases/quantity_aggregation_service.dart';
import 'settings_provider.dart';

/// Provider для управления статистикой
class StatisticsProvider with ChangeNotifier {
  final EntryRepository _entryRepository;
  final UnitRepository _unitRepository;

  final SettingsProvider? _settings;

  /// [settings] необязателен: без него неделя начинается с понедельника.
  StatisticsProvider(
    this._entryRepository,
    this._unitRepository, [
    this._settings,
  ]) {
    _appliedWeekStart = weekStartsOnMonday;
    _settings?.addListener(_onSettingsChanged);
    _loadData();
  }

  @override
  void dispose() {
    _settings?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// Начало недели, с которым загружены текущие данные.
  late bool _appliedWeekStart;

  bool get weekStartsOnMonday =>
      _settings?.weekStartsOnMonday ?? AppConstants.defaultWeekStartsOnMonday;

  void _onSettingsChanged() {
    if (weekStartsOnMonday == _appliedWeekStart) return;
    if (_selectedPeriod == PeriodType.week) {
      _loadData();
    } else {
      _appliedWeekStart = weekStartsOnMonday;
      notifyListeners();
    }
  }

  PeriodType _selectedPeriod = PeriodType.month;
  DateTime _selectedDate = DateTime.now();

  List<Entry> _entries = [];
  List<Unit> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  PeriodType get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Получить агрегацию денег
  List<MoneyAggregation> get moneyAggregations {
    return MoneyAggregationService.getAggregationsList(
      entries: _entries,
      units: _units,
    );
  }

  /// Получить агрегацию количеств
  List<QuantityAggregation> get quantityAggregations {
    return QuantityAggregationService.getAggregationsList(
      entries: _entries,
      units: _units,
    );
  }

  /// Получить количество записей
  int get entriesCount => _entries.length;

  /// Изменить период
  void setPeriod(PeriodType period) {
    _selectedPeriod = period;
    notifyListeners();
    _loadData();
  }

  /// Изменить дату
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    _loadData();
  }

  /// Загрузить данные
  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Получить границы периода
      _appliedWeekStart = weekStartsOnMonday;
      final range = DateTimeUtils.getPeriodRange(
        _selectedDate,
        _selectedPeriod,
        weekStartsOnMonday: weekStartsOnMonday,
      );

      // Загрузить записи за период
      _entries = await _entryRepository.getAllEntriesByPeriod(
        startDate: range.start,
        endDate: range.end,
      );

      // Загрузить единицы измерения
      _units = await _unitRepository.getAllUnits();
    } catch (e) {
      _errorMessage = 'Ошибка загрузки статистики: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновить данные
  Future<void> refreshData() async {
    await _loadData();
  }
}
