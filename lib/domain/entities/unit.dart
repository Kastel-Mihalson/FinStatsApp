/// Тип единицы измерения
enum UnitKind {
  currency,
  count,
}

/// Единица измерения (валюта или количественная единица)
class Unit {
  final int id;
  final String code;
  final UnitKind kind;
  final String displayName;

  const Unit({
    required this.id,
    required this.code,
    required this.kind,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'kind': kind == UnitKind.currency ? 'CURRENCY' : 'COUNT',
      'displayName': displayName,
    };
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      code: json['code'] as String,
      kind: json['kind'] == 'CURRENCY' ? UnitKind.currency : UnitKind.count,
      displayName: json['displayName'] as String,
    );
  }
}
