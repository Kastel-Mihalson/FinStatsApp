import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

/// Тип значения записи
enum ValueType {
  @JsonValue('MONEY')
  money,
  @JsonValue('QUANTITY')
  quantity,
}

/// Запись (событие) в разделе
@freezed
class Entry with _$Entry {
  const factory Entry({
    required String id,
    required String sectionId,
    required String description,
    required ValueType valueType,
    required int amount, // для денег — копейки, для количеств — с фиксированной точностью
    required int unitId,
    required DateTime occurredAt,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
