import 'dart:convert';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<List<Order>> getOrdersByUser() async {
    try {
      final response = await ApiService.get('orders/history');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody['data'];
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

  //cancelar pedido
  static Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/cancel');

      if (response.statusCode == 200) {
        print('Pedido cancelado correctamente');
        return true;
      } else {
        print('Error al cancelar el pedido: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al cancelar pedido: $e');
      return false;
    }
  }

  // Confirmar pedido como vendedor
  static Future<bool> confirmOrderByVendor(int orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/confirm?vendor=true');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al confirmar pedido como vendedor: $e');
      return false;
    }
  }

// Marcar como entregado
  static Future<bool> markOrderAsDelivered(int orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/deliver');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al marcar como entregado: $e');
      return false;
    }
  }

// Cancelar pedido como vendedor
  static Future<bool> cancelOrderByVendor(int orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/cancel?vendor=true');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al cancelar pedido como vendedor: $e');
      return false;
    }
  }


}
