import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

/// Тип единицы измерения
enum UnitKind {
  @JsonValue('CURRENCY')
  currency,
  @JsonValue('COUNT')
  count,
}

/// Единица измерения (валюта или количественная единица)
@freezed
class Unit with _$Unit {
  const factory Unit({
    required int id,
    required String code,
    required UnitKind kind,
    required String displayName,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
