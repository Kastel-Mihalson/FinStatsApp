import 'package:freezed_annotation/freezed_annotation.dart';

part 'section.freezed.dart';
part 'section.g.dart';

/// Раздел для группировки записей
@freezed
class Section with _$Section {
  const factory Section({
    required String id,
    required String name,
    String? icon,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Section;

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
}
