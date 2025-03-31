import 'api_service.dart';

class AuthService {
  // Login
  Future<bool> login(String email, String password) async {
    final response = await ApiService.post('auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      // Guardar token si es necesario
      // Ejemplo: await SecureStorage.saveToken(response.body['token']);
      return true;
    }
    return false;
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