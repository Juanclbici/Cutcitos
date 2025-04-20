import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../api_service.dart';
import '../user/user_service.dart';
import '../../models/User.dart';
import '../../providers/auth_provider.dart';

class AuthService {
  // 🔐 Login con AuthProvider
  Future<bool> login(BuildContext context, String email, String password) async {
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        // Manejar sesión global
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(token);

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error en login: $e');
      rethrow;
    }
  }

  // 📝 Registro con AuthProvider
  Future<Map<String, dynamic>> register({
    required BuildContext context,
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

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final token = body['token'];

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(token);
    }

    return {
      'success': response.statusCode == 200,
      'message': body['message'] ?? 'Registro exitoso',
    };
  }

  // 🔁 Recuperar contraseña
  Future<bool> resetPassword(String email) async {
    final response = await ApiService.post('auth/forgot-password', {
      'email': email,
    });

    return response.statusCode == 200;
  }

  // 🚪 Cerrar sesión desde AuthProvider
  Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }
}
