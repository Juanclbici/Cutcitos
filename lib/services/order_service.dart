import 'dart:convert';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<List<Order>> getOrdersByUser(int userId) async {
    try {
      final response = await ApiService.get('orders/user/$userId');

      if (response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener órdenes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en OrderService: $e');
      rethrow;
    }
  }

  static Future<int?> createOrderLote({
    required int vendedorId,
    required List<Map<String, dynamic>> productos,
    required String metodoPago,
    required String direccion,
  }) async {
    try {
      final response = await ApiService.post('orders', {
        'vendedor_id': vendedorId,
        'productos': productos,
        'metodo_pago': metodoPago,
        'direccion_entrega': direccion,
      });

      print('Respuesta del backend: ${response.body}');
      print('Código de estado: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['order_id']; // <-- importante
      } else {
        return null;
      }
    } catch (e) {
      print('Error al crear pedido: $e');
      return null;
    }
  }




  static Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await ApiService.delete('orders/$orderId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al cancelar pedido: $e');
      return false;
    }
  }

  // Obtener pedidos por vendedor (autenticado)
  static Future<List<Order>> getOrdersBySeller() async {
    try {
      final response = await ApiService.get('orders/vendor');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody['data'];
        return data.map((e) => Order.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener pedidos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener pedidos del vendedor: $e');
      rethrow;
    }
  }

  // Confirmar pedido
  static Future<bool> confirmOrder(int orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/confirm');

      return response.statusCode == 200;
    } catch (e) {
      print('Error al confirmar pedido: $e');
      return false;
    }
  }
}
