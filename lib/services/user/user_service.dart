import 'dart:convert';
import '../../models/User.dart';
import '../api_service.dart';
import '../cloudinary/cloudinary_service.dart';

class UserService {
  static Future<User> getCurrentUser() async {
    final response = await ApiService.get('users/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }

  static Future<bool> updateProfile({String? fotoPerfilUrl}) async {
    final Map<String, dynamic> data = {};
    if (fotoPerfilUrl != null) {
      data['foto_perfil'] = fotoPerfilUrl;
    }

    final response = await ApiService.putWithBody('users/profile', data);
    return response.statusCode == 200;
  }

  static Future<bool> subirFotoPerfilFirmada() async {
    final url = await CloudinaryService.subirImagenFirmada(folder: 'usuarios');
    if (url == null) return false;
    return await updateProfile(fotoPerfilUrl: url);
  }
}
