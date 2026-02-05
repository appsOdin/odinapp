import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utlis/constants.dart';

class LoginService {
    static const String _baseUrl = Constants.apiBaseUrl;
   /// Login de usuario. Retorna el response completo (ejemplo: {'success':true, 'token':...})
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/User/Login");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  /// Logout de usuario. Envía el token en el header
  static Future<Map<String, dynamic>> logout({required String token}) async {
    final url = Uri.parse("$_baseUrl/User/Logout");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }
}