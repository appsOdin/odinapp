import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utlis/constants.dart';

class UserService {
  // Base URL de tu API –– cámbiala a la de tu backend
  static const String _baseUrl = Constants.apiBaseUrl;

  /// Crear usuario. Retorna el response completo
  static Future<Map<String, dynamic>> createSuscriber({
    required String id,
    required String name,
    required String lastName,
    required String username,
    required String password,
    required String email,
  }) async {
    final url = Uri.parse("$_baseUrl/User/CreateSuscriber");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'lastname': lastName,
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  // Puedes agregar más métodos aquí, por ejemplo:
  // static Future<Map<String, dynamic>> getUserData(String token) { ... }

  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$_baseUrl/User/UpdatePassword");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'newPassword': newPassword,
        'oldPassword': oldPassword,
      }),
    );

    Map<String, dynamic> payload = {};
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          payload = parsed;
        }
      } catch (_) {
        payload = {};
      }
    }

    if (response.statusCode == 200) {
      return payload.isNotEmpty
          ? payload
          : {
              'code': response.statusCode.toString(),
              'message': 'Contraseña actualizada correctamente',
            };
    }

    return payload.isNotEmpty
        ? payload
        : {
            'code': response.statusCode.toString(),
            'message': 'No se pudo actualizar la contraseña',
          };
  }
}
