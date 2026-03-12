import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';

class ApiService {
  static const String baseUrl = ServerConfig.baseUrl;
  static Future<String> testPredict() async {
    final uri = Uri.parse('$baseUrl/');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'No message';
    } else {
      throw Exception('Failed to connect: ${response.statusCode}');
    }
  }
}