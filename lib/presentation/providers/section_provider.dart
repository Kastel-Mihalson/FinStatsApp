import 'package:flutter/foundation.dart';

import '../../domain/entities/section.dart';
import '../../domain/repositories/section_repository.dart';

/// Provider для управления разделами
class SectionProvider with ChangeNotifier {
  final SectionRepository _repository;

  SectionProvider(this._repository) {
    _loadSections();
  }

  List<Section> _sections = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Section> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Загрузить все разделы
  Future<void> _loadSections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sections = await _repository.getAllSections();
    } catch (e) {
      _errorMessage = 'Ошибка загрузки разделов: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновить список разделов
  Future<void> refreshSections() async {
    await _loadSections();
  }

  /// Создать новый раздел
  Future<void> createSection(Section section) async {
    try {
      await _repository.createSection(section);
      await _loadSections();
    } catch (e) {
      _errorMessage = 'Ошибка создания раздела: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Обновить раздел
  Future<void> updateSection(Section section) async {
    try {
      await _repository.updateSection(section);
      await _loadSections();
    } catch (e) {
      _errorMessage = 'Ошибка обновления раздела: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Удалить раздел
  Future<void> deleteSection(String id) async {
    try {
      await _repository.deleteSection(id);
      await _loadSections();
    } catch (e) {
      _errorMessage = 'Ошибка удаления раздела: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Получить раздел по ID
  Future<Section?> getSectionById(String id) async {
    try {
      return await _repository.getSectionById(id);
    } catch (e) {
      _errorMessage = 'Ошибка загрузки раздела: $e';
      notifyListeners();
      return null;
    }
  }
}
