import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get _baseUrl {
    return dotenv.get('API_URL'); // Obtiene la URL del .env
  }
  // Método genérico para POST
  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = '$_baseUrl/$endpoint';
    try {
      return await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      print('Error en POST $endpoint: $e');
      rethrow;
    }
  }

  // Método genérico para GET (útil para otros servicios)
  static Future<http.Response> get(String endpoint) async {
    try {
      return await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error en GET $endpoint: $e');
      rethrow;
    }
  }
}