/// Модель для хранения Entry в БД
class EntryModel {
  final String id;
  final String sectionId;
  final String description;
  final String valueType; // 'MONEY' или 'QUANTITY'
  final int amount;
  final int unitId;
  final int occurredAt; // timestamp в миллисекундах
  final String? note;
  final int createdAt;
  final int updatedAt;

  const EntryModel({
    required this.id,
    required this.sectionId,
    required this.description,
    required this.valueType,
    required this.amount,
    required this.unitId,
    required this.occurredAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'description': description,
      'value_type': valueType,
      'amount': amount,
      'unit_id': unitId,
      'occurred_at': occurredAt,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] as String,
      sectionId: map['section_id'] as String,
      description: map['description'] as String,
      valueType: map['value_type'] as String,
      amount: map['amount'] as int,
      unitId: map['unit_id'] as int,
      occurredAt: map['occurred_at'] as int,
      note: map['note'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }
}
