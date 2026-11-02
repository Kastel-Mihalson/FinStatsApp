import '../../domain/entities/section.dart';
import '../models/section_model.dart';

/// Маппер Section: data ↔ domain
class SectionMapper {
  /// Преобразование SectionModel (БД) → Section (domain)
  static Section toEntity(SectionModel model) {
    return Section(
      id: model.id,
      name: model.name,
      icon: model.icon,
      color: model.color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(model.updatedAt),
    );
  }

  /// Преобразование Section (domain) → SectionModel (БД)
  static SectionModel toModel(Section entity) {
    return SectionModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Преобразование списка
  static List<Section> toEntityList(List<SectionModel> models) {
    return models.map(toEntity).toList();
  }
}
