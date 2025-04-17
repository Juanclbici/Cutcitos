class Order {
  final int id;
  final int userId;
  final int vendedorId;
  final double total;
  final String estado;
  final DateTime fecha;

  Order({
    required this.id,
    required this.userId,
    required this.vendedorId,
    required this.total,
    required this.estado,
    required this.fecha,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['order_id'],
      userId: json['user_id'],
      vendedorId: json['vendedor_id'],
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      estado: json['estado'] ?? '',
      fecha: DateTime.tryParse(json['fecha']) ?? DateTime.now(),
    );
  }
}
