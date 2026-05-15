import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/constants.dart';
import 'request_context.dart';

class UploadApi {
  Future<bool> uploadProfilePicture(
    String matricula,
    String token,
    String filePath, {
    Uint8List? webBytes,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/students/$matricula/avatar');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(await RequestContext.headers(token: token));

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

      if (response.statusCode == 204) {
        return true;
      }
      debugPrint('Erro upload: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Erro ao enviar foto: $e');
      return false;
    }
  }
}
