import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utlis/constants.dart';

class ApiService {
  // Base URL de tu API –– cámbiala a la de tu backend
  static const String _baseUrl = Constants.apiBaseUrl;

  /// Crear usuario. Retorna el response completo
  static Future<Map<String, dynamic>> createUser({
    required String identificacion,
    required String nombre,
    required String apellidos,
    required String usuario,
    required String contrasena,
    required String correo,
  }) async {
    final url = Uri.parse("$_baseUrl/User/CreateUser");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Identificacion': identificacion,
        'Nombre': nombre,
        'Apellidos': apellidos,
        'Usuario': usuario,
        'Contrasena': contrasena,
        'Correo': correo,
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
}