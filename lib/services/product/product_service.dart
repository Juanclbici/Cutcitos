import 'dart:convert';
import '../../models/product.dart';
import '../api_service.dart';

class ProductService {
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await ApiService.get('products');

      print("Respuesta completa de productos:");
      print("Status: ${response.statusCode}");

      // Imprime el cuerpo en partes si es muy grande
      final responseBody = response.body;
      const chunkSize = 1000; // Divide en chunks de 1000 caracteres
      for (var i = 0; i < responseBody.length; i += chunkSize) {
        final end = (i + chunkSize < responseBody.length) ? i + chunkSize : responseBody.length;
        print("Body part: ${responseBody.substring(i, end)}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> productsData = responseData['data'];
          print("Número de productos recibidos: ${productsData.length}");

          // Imprime cada producto individualmente
          for (var product in productsData) {
            print("Producto: ${product['nombre']} - ${product['producto_id']}");
          }

          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception('Error del servidor: ${responseData['message']}');
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error completo al obtener productos: $e");
      rethrow;
    }
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await ApiService.get('products/category/$categoryId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> productsData = responseData['data'];
          return productsData.map((json) => Product.fromJson(json)).toList();
        }
      }
      throw Exception('Error al cargar productos: ${response.statusCode}');
    } catch (e) {
      print("Error al obtener productos por categoría: $e");
      rethrow;
    }
  }

  static Future<List<Product>> getMyProducts() async {
    try {
      final response = await ApiService.get('products/vendor/my-products');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        }
      }
      throw Exception('Error al cargar tus productos');
    } catch (e) {
      print('Error en getMyProducts: $e');
      rethrow;
    }
  }
  static Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await ApiService.post('products', productData);

      if (response.statusCode == 201) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear producto');
      }
    } catch (e) {
      print('Error al crear producto: $e');
      rethrow;
    }
  }
  static Future<bool> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      print("📦 Datos que se enviarán al backend: $productData");
      final response = await ApiService.putWithBody('products/$productId', productData);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar producto');
      }
    } catch (e) {
      print('Error al actualizar producto: $e');
      rethrow;
    }
  }

  static Future<bool> deleteProduct(int productId) async {
    try {
      final response = await ApiService.delete('products/$productId');

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'No se pudo eliminar');
      }
    } catch (e) {
      print('Error al eliminar producto: $e');
      rethrow;
    }
  }




}