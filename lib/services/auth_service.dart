import 'api_service.dart';
import 'dart:convert';

class AuthService {
  // Login
  Future<bool> login(String email, String password) async {  // Cambia de void a bool
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await ApiService.setToken(data['token']);
        return true;  // Devuelve true si el login es exitoso
      }
      return false;  // Devuelve false si falla
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Registro
  Future<bool> register({
    required String codigo,
    required String password,
    required String nombre,
    required String rol,
    required String telefono,
    required String email,
  }) async {
    final response = await ApiService.post('auth/register', {
      'codigo_UDG': codigo,
      'password': password,
      'nombre': nombre,
      'rol': rol,
      'telefono': telefono,
      'email': email,
    });

    return response.statusCode == 201;
  }

  // Recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    final response = await ApiService.post('auth/forgot-password', {
      'email': email,
    });

    return response.statusCode == 200;
  }
}