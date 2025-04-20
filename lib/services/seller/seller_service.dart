import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/seller.dart';
import '../api_service.dart';

class SellerService {
  static Future<List<Seller>> getAllSellers() async {
    try {
      final response = await ApiService.get('users/sellers');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Seller.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener vendedores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en SellerService: $e');
      rethrow;
    }
  }
}
