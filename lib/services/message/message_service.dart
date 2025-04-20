import 'dart:convert';
import '../../models/message.dart';
import '../api_service.dart';

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
}
