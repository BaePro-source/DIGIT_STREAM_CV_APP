import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';

class ApiService {

  static Future<int> sendImage(Uint8List imageBytes) async {

    final uri = Uri.parse('${ServerConfig.baseUrl}/predict');

    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'frame.jpg',
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    return data['prediction'];
  }
}