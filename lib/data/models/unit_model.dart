/// Модель для хранения Unit в БД
class UnitModel {
  final int id;
  final String code;
  final String kind; // 'CURRENCY' или 'COUNT'
  final String displayName;

  const UnitModel({
    required this.id,
    required this.code,
    required this.kind,
    required this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'kind': kind,
      'display_name': displayName,
    };
  }

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['id'] as int,
      code: map['code'] as String,
      kind: map['kind'] as String,
      displayName: map['display_name'] as String,
    );
  }
}
