import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/constants.dart';

class UploadApi {
  Future<bool> uploadProfilePicture(
    String matricula,
    String token,
    String filePath, {
    Uint8List? webBytes,
  }) async {
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula/foto');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    if (kIsWeb && webBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Erro upload: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao enviar foto: $e');
      return false;
    }
  }
}
