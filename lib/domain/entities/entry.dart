/// Тип значения записи
enum ValueType {
  money,
  quantity,
}

/// Запись (событие) в разделе
class Entry {
  final String id;
  final String sectionId;
  final String description;
  final ValueType valueType;
  final int amount; // для денег — копейки, для количеств — с фиксированной точностью
  final int unitId;
  final DateTime occurredAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Entry({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionId': sectionId,
      'description': description,
      'valueType': valueType == ValueType.money ? 'MONEY' : 'QUANTITY',
      'amount': amount,
      'unitId': unitId,
      'occurredAt': occurredAt.millisecondsSinceEpoch,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String,
      description: json['description'] as String,
      valueType: json['valueType'] == 'MONEY' ? ValueType.money : ValueType.quantity,
      amount: json['amount'] as int,
      unitId: json['unitId'] as int,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(json['occurredAt'] as int),
      note: json['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}
