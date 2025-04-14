// lib/services/user_service.dart
import 'dart:convert';
import '../models/User.dart'; // (Ahora crearemos un modelo limpio)
import 'api_service.dart';

class UserService {
  static Future<User> getCurrentUser() async {
    try {
      final response = await ApiService.get('users/profile'); // Ruta protegida

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en UserService: $e");
      rethrow;
    }
  }
}
