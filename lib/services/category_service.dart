// services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getAllCategories() async {
    try {
      print("Solicitando categorías al backend...");
      final response = await ApiService.get('categories');

      print("Respuesta recibida: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Accede al array dentro de la propiedad 'data'
        final List<dynamic> categoriesData = responseData['data'];
        print("Categorías parseadas: $categoriesData");

        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en CategoryService: $e");
      rethrow;
    }
  }
}