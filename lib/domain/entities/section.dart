/// Раздел для группировки записей
class Section {
  final String id;
  final String name;
  final String icon;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Section({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}
