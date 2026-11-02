import 'package:flutter/foundation.dart';

import '../../domain/entities/unit.dart';
import '../../domain/repositories/unit_repository.dart';

/// Provider для управления единицами измерения
class UnitProvider with ChangeNotifier {
  final UnitRepository _repository;

  UnitProvider(this._repository) {
    _loadUnits();
  }

  List<Unit> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Получить валюты
  List<Unit> get currencies =>
      _units.where((u) => u.kind == UnitKind.currency).toList();

  /// Получить единицы измерения количеств
  List<Unit> get countUnits =>
      _units.where((u) => u.kind == UnitKind.count).toList();

  /// Загрузить все единицы
  Future<void> _loadUnits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _units = await _repository.getAllUnits();
    } catch (e) {
      _errorMessage = 'Ошибка загрузки единиц измерения: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновить список единиц
  Future<void> refreshUnits() async {
    await _loadUnits();
  }

  /// Получить единицу по ID
  Unit? getUnitById(int id) {
    try {
      return _units.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
