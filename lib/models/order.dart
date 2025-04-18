import 'product.dart';

class Order {
  final int id;
  final int userId;
  final int vendedorId;
  final double total;
  final String estado;
  final DateTime fecha;
  final int productoId;
  final List<Product> productos;
  final String? vendedorNombre;

  Order({
    required this.id,
    required this.userId,
    required this.vendedorId,
    required this.total,
    required this.estado,
    required this.fecha,
    this.productoId = 0,
    required this.productos,
    this.vendedorNombre,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var productosJson = json['Productos'] ?? [];
    List<Product> productosParsed = List<Product>.from(
      productosJson.map((p) => Product.fromJson(p)),
    );

    return Order(
      id: json['pedido_id'],
      userId: json['usuario_id'],
      vendedorId: json['vendedor_id'],
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      estado: json['estado_pedido'] ?? '',
      fecha: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      productoId: json['producto_id'] ?? 0,
      productos: productosParsed,
      vendedorNombre: productosParsed.isNotEmpty
          ? productosParsed.first.sellerName
          : 'Desconocido',
    );
  }
}
