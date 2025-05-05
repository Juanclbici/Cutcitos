import 'dart:convert';
import '../../models/message.dart';
import '../../models/Seller.dart';
import '../api_service.dart';
import '../../models/User.dart';

class MessageService {
  static Future<List<Message>> getMessages(int emisorId, int receptorId) async {
    try {
      final response = await ApiService.get('messages/$emisorId/$receptorId');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en MessageService: $e');
      rethrow;
    }
  }

  static Future<bool> sendMessage(Map<String, dynamic> msgData) async {
    try {
      final response = await ApiService.post('messages', msgData);
      return response.statusCode == 201;
    } catch (e) {
      print('Error al enviar mensaje: $e');
      return false;
    }
  }

  // NUEVO: Obtener inbox del usuario autenticado
  static Future<List<Map<String, dynamic>>> getInbox() async {
    try {
      final response = await ApiService.get('messages/inbox');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'usuario_id': item['usuario_id'],
          'ultimo_mensaje': item['ultimo_mensaje'],
          'fecha': item['fecha'],
          'no_leido': item['no_leido']
        }).toList();
      } else {
        throw Exception('Error al obtener inbox: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getInbox: $e');
      rethrow;
    }
  }

  // NUEVO: obtener conversación real con un usuario
  static Future<List<Message>> getMessagesWith(int otherUserId) async {
    try {
      final response = await ApiService.get('messages/conversation/$otherUserId');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener conversación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getMessagesWith: $e');
      rethrow;
    }
  }


  static Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get('users');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllUsers: $e');
      rethrow;
    }
  }


}
