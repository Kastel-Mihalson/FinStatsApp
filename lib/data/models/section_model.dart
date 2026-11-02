/// Модель для хранения Section в БД
class SectionModel {
  final String id;
  final String name;
  final String icon;
  final int color; // Хранится как int (0xFFRRGGBB)
  final int createdAt; // timestamp в миллисекундах
  final int updatedAt;

  const SectionModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.toString(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: (map['icon'] as String?) ?? '📁', // Дефолтная иконка
      color: map['color'] != null
          ? int.parse(map['color'] as String)
          : 0xFF2196F3, // Дефолтный синий цвет
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }
}
