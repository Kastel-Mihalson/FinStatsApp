import '../../domain/entities/entry.dart';
import '../models/entry_model.dart';

/// Маппер Entry: data ↔ domain
class EntryMapper {
  /// Преобразование EntryModel (БД) → Entry (domain)
  static Entry toEntity(EntryModel model) {
    return Entry(
      id: model.id,
      sectionId: model.sectionId,
      description: model.description,
      valueType: model.valueType == 'MONEY' ? ValueType.money : ValueType.quantity,
      amount: model.amount,
      unitId: model.unitId,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(model.occurredAt),
      note: model.note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(model.updatedAt),
    );
  }

  /// Преобразование Entry (domain) → EntryModel (БД)
  static EntryModel toModel(Entry entity) {
    return EntryModel(
      id: entity.id,
      sectionId: entity.sectionId,
      description: entity.description,
      valueType: entity.valueType == ValueType.money ? 'MONEY' : 'QUANTITY',
      amount: entity.amount,
      unitId: entity.unitId,
      occurredAt: entity.occurredAt.millisecondsSinceEpoch,
      note: entity.note,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Преобразование списка
  static List<Entry> toEntityList(List<EntryModel> models) {
    return models.map(toEntity).toList();
  }
}
