import '../../domain/entities/unit.dart';
import '../models/unit_model.dart';

/// Маппер Unit: data ↔ domain
class UnitMapper {
  /// Преобразование UnitModel (БД) → Unit (domain)
  static Unit toEntity(UnitModel model) {
    return Unit(
      id: model.id,
      code: model.code,
      kind: model.kind == 'CURRENCY' ? UnitKind.currency : UnitKind.count,
      displayName: model.displayName,
    );
  }

  /// Преобразование Unit (domain) → UnitModel (БД)
  static UnitModel toModel(Unit entity) {
    return UnitModel(
      id: entity.id,
      code: entity.code,
      kind: entity.kind == UnitKind.currency ? 'CURRENCY' : 'COUNT',
      displayName: entity.displayName,
    );
  }

  /// Преобразование списка
  static List<Unit> toEntityList(List<UnitModel> models) {
    return models.map(toEntity).toList();
  }
}
