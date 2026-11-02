import 'package:flutter/foundation.dart';

import '../../domain/entities/entry.dart';
import '../../domain/repositories/entry_repository.dart';

/// Provider для управления записями
class EntryProvider with ChangeNotifier {
  final EntryRepository _repository;

  EntryProvider(this._repository);

  List<Entry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSectionId;

  List<Entry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Загрузить записи раздела
  Future<void> loadEntriesBySection(String sectionId) async {
    _currentSectionId = sectionId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _repository.getEntriesBySection(sectionId);
    } catch (e) {
      _errorMessage = 'Ошибка загрузки записей: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузить записи за период
  Future<void> loadEntriesByPeriod({
    required String sectionId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _currentSectionId = sectionId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _repository.getEntriesByPeriod(
        sectionId: sectionId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = 'Ошибка загрузки записей: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновить текущий список записей
  Future<void> refreshEntries() async {
    if (_currentSectionId != null) {
      await loadEntriesBySection(_currentSectionId!);
    }
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
