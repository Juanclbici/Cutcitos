import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  /// Sube una imagen firmada a Cloudinary dentro de la carpeta especificada.
  static Future<String?> subirImagenFirmada({required String folder}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final backendUrl = dotenv.get('API_URL');

    // Solicita firma al backend, enviando la carpeta correcta
    final firmaResponse = await http.post(
      Uri.parse('$backendUrl/cloudinary/signature'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'upload_preset': 'cutcitos_firmado',
        'folder': folder,
      }),
    );

    if (firmaResponse.statusCode != 200) {
      print('❌ Error al obtener firma: ${firmaResponse.body}');
      return null;
    }

    final data = json.decode(firmaResponse.body);
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/${data['cloudName']}/image/upload');

    // Prepara la solicitud Multipart con la carpeta dinámica
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = data['apiKey']
      ..fields['timestamp'] = data['timestamp'].toString()
      ..fields['upload_preset'] = data['uploadPreset']
      ..fields['folder'] = data['folder']
      ..fields['signature'] = data['signature']
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final uploadedData = json.decode(resBody);
      print('✅ Imagen subida a carpeta ${data['folder']}');
      return uploadedData['secure_url'];
    } else {
      print('❌ Error al subir imagen: $resBody');
      return null;
    }
  }
}
