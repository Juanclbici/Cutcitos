import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static String? _token;

  static String get _baseUrl {
    return dotenv.get('API_URL');
  }

  // Inicializar el token al iniciar la app
  static Future<void> initialize() async {
    _token = await _secureStorage.read(key: 'auth_token');
  }

  // Guardar token (al hacer login)
  static Future<void> setToken(String token) async {
    _token = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Eliminar token (al hacer logout)
  static Future<void> clearToken() async {
    _token = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  // Método genérico para GET
  static Future<http.Response> get(String endpoint) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token', // Verifica que tenga 'Bearer '
      };

      print("Headers: $headers"); // Debug
      print("URL: $_baseUrl/$endpoint"); // Debug

      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
      );

      print("Response status: ${response.statusCode}"); // Debug
      return response;
    } catch (e) {
      print('Error en GET $endpoint: $e');
      rethrow;
    }
  }

  // Método genérico para POST
  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      _checkAuthError(response);
      return response;
    } catch (e) {
      print('Error en POST $endpoint: $e');
      rethrow;
    }
  }

  // Verificar errores de autenticación
  static void _checkAuthError(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Podrías agregar lógica para manejar el logout automático aquí
      throw Exception('Error de autenticación: ${response.statusCode}');
    }
  }

  // Método genérico para DELETE
  static Future<http.Response> delete(String endpoint) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
      );

      _checkAuthError(response);
      return response;
    } catch (e) {
      print('Error en DELETE $endpoint: $e');
      rethrow;
    }
  }

  // Método PUT genérico
  static Future<http.Response> put(String endpoint) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
      );

      _checkAuthError(response);
      return response;
    } catch (e) {
      print('Error en PUT $endpoint: $e');
      rethrow;
    }
  }

  // Método PUT con body (para productos u otras actualizaciones)
  static Future<http.Response> putWithBody(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      _checkAuthError(response);
      return response;
    } catch (e) {
      print('Error en PUT con body $endpoint: $e');
      rethrow;
    }
  }


}