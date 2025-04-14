// models/category.dart
class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoria_id'],
      name: json['nombre'],
      description: json['descripcion'],
      image: json['imagen'],
    );
  }
}