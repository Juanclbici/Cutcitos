class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int availableQuantity;
  final String image;
  final int categoryId;
  final int sellerId;
  final String sellerName;
  final String categoryName;
  final int? cantidadSolicitada;
  final String status;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.availableQuantity,
    required this.image,
    required this.categoryId,
    required this.sellerId,
    required this.sellerName,
    required this.categoryName,
    required this.cantidadSolicitada,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['producto_id'],
      name: json['nombre'],
      description: json['descripcion'],
      price: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
      availableQuantity: json['cantidad_disponible'],
      image: json['imagen'] ?? 'default_product.png',
      categoryId: json['categoria_id'],
      sellerId: json['vendedor_id'],
      sellerName: json['Vendedor']?['nombre'] ?? 'Vendedor desconocido',
      categoryName: json['Categoria']?['nombre'] ?? 'Sin categoría',
      cantidadSolicitada: json['OrderItem']?['cantidad'],
      status: json['estado_producto'] ?? 'disponible',
    );
  }
}