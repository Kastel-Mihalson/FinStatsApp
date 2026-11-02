import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/sort_type.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/entry.dart';
import '../../domain/repositories/entry_repository.dart';

/// Provider для управления записями раздела:
/// список, выбранный период (с навигацией назад/вперёд) и сортировка.
class EntryProvider with ChangeNotifier {
  final EntryRepository _repository;

  EntryProvider(this._repository);

  List<Entry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSectionId;

  PeriodType _period = PeriodType.all;
  DateTime _anchorDate = DateTime.now();
  SortType _sort = SortType.dateNewest;
  bool _weekStartsOnMonday = AppConstants.defaultWeekStartsOnMonday;

  /// Номер последнего запроса: ответы устаревших запросов игнорируются
  /// (например, пользователь быстро переключает периоды).
  int _loadId = 0;

  /// Записи текущего раздела за выбранный период, уже отсортированные.
  List<Entry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PeriodType get period => _period;
  DateTime get anchorDate => _anchorDate;
  SortType get sort => _sort;
  bool get weekStartsOnMonday => _weekStartsOnMonday;

  /// Можно ли листать периоды (для «Всё время» — нет).
  bool get canNavigatePeriod => _period != PeriodType.all;

  /// Подпись выбранного периода («Ноябрь 2026» и т.п.).
  String get periodLabel => DateTimeUtils.formatPeriodLabel(
        _anchorDate,
        _period,
        weekStartsOnMonday: _weekStartsOnMonday,
      );

  /// Открыть раздел: сбрасывает период на «Всё время» и сортировку на
  /// «новые первыми», затем загружает записи.
  Future<void> openSection(String sectionId) {
    _currentSectionId = sectionId;
    _period = PeriodType.all;
    _anchorDate = DateTime.now();
    _sort = SortType.dateNewest;
    _entries = [];
    return _load();
  }

  /// Загрузить записи раздела (то же, что [openSection]).
  Future<void> loadEntriesBySection(String sectionId) => openSection(sectionId);

  /// Выбрать тип периода; опорной датой становится сегодняшний день.
  Future<void> setPeriod(PeriodType period) {
    _period = period;
    _anchorDate = DateTime.now();
    return _load();
  }

  /// Перейти к предыдущему периоду.
  Future<void> previousPeriod() => _shift(-1);

  /// Перейти к следующему периоду.
  Future<void> nextPeriod() => _shift(1);

  Future<void> _shift(int steps) {
    if (!canNavigatePeriod) return Future.value();
    _anchorDate = DateTimeUtils.shiftDate(_anchorDate, _period, steps);
    return _load();
  }

  /// Изменить сортировку (список пересортировывается без обращения к БД).
  void setSort(SortType sort) {
    if (_sort == sort) return;
    _sort = sort;
    _entries = _sorted(_entries);
    notifyListeners();
  }

  /// Начало недели (для будущего экрана настроек).
  Future<void> setWeekStartsOnMonday(bool value) {
    if (_weekStartsOnMonday == value) return Future.value();
    _weekStartsOnMonday = value;
    if (_period == PeriodType.week) return _load();
    notifyListeners();
    return Future.value();
  }

  /// Обновить текущий список записей (с сохранением периода и сортировки).
  Future<void> refreshEntries() => _load();

  Future<void> _load() async {
    final sectionId = _currentSectionId;
    if (sectionId == null) return;

    final loadId = ++_loadId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Entry> loaded;
      if (_period == PeriodType.all) {
        loaded = await _repository.getEntriesBySection(sectionId);
      } else {
        final range = DateTimeUtils.getPeriodRange(
          _anchorDate,
          _period,
          weekStartsOnMonday: _weekStartsOnMonday,
        );
        loaded = await _repository.getEntriesByPeriod(
          sectionId: sectionId,
          startDate: range.start,
          endDate: range.end,
        );
      }
      if (loadId != _loadId) return;
      _entries = _sorted(loaded);
    } catch (e) {
      if (loadId != _loadId) return;
      _errorMessage = 'Ошибка загрузки записей: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Сортировка по дате или по значению. При сортировке по значению сравниваются
  /// хранимые числа как есть (без учёта валюты/единицы); равные — по дате.
  List<Entry> _sorted(List<Entry> source) {
    final list = List<Entry>.of(source);
    int byDateDesc(Entry a, Entry b) => b.occurredAt.compareTo(a.occurredAt);

    list.sort((a, b) {
      switch (_sort) {
        case SortType.dateNewest:
          return byDateDesc(a, b);
        case SortType.dateOldest:
          return a.occurredAt.compareTo(b.occurredAt);
        case SortType.amountHighest:
          final c = b.amount.compareTo(a.amount);
          return c != 0 ? c : byDateDesc(a, b);
        case SortType.amountLowest:
          final c = a.amount.compareTo(b.amount);
          return c != 0 ? c : byDateDesc(a, b);
      }
    });
    return list;
  }

  /// Создать запись
  Future<void> createEntry(Entry entry) async {
    try {
      await _repository.createEntry(entry);
      await refreshEntries();
    } catch (e) {
      _errorMessage = 'Ошибка создания записи: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Обновить запись
  Future<void> updateEntry(Entry entry) async {
    try {
      await _repository.updateEntry(entry);
      await refreshEntries();
    } catch (e) {
      _errorMessage = 'Ошибка обновления записи: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Удалить запись
  Future<void> deleteEntry(String id) async {
    try {
      await _repository.deleteEntry(id);
      await refreshEntries();
    } catch (e) {
      _errorMessage = 'Ошибка удаления записи: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Получить запись по ID
  Future<Entry?> getEntryById(String id) async {
    try {
      return await _repository.getEntryById(id);
    } catch (e) {
      _errorMessage = 'Ошибка загрузки записи: $e';
      notifyListeners();
      return null;
    }
  }
}
