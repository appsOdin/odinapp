import 'package:flutter/material.dart';
import '../services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  Future<bool> login(BuildContext context) async {
    String user = usernameCtrl.text.trim();
    String pass = passwordCtrl.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      _showAlert(context, "Error", "Por favor, completa todos los campos");
      return false;
    }

    try {
      // Llama al método login del LoginService
      final result = await LoginService.login(username: user, password: pass);

      if (result['code'] == "200") {
        
        // Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', result['data']['token']);

        _showAlert(context, "¡Éxito!", "Inicio de sesión correcto");
        return true;
      } else {
        // Muestra el mensaje de error del backend si existe
        _showAlert(context, "Error", result['message'] ?? "Credenciales incorrectas");
        return false;
      }
    } catch (e) {
      _showAlert(context, "Error", "No se pudo conectar al servidor.\n$e");
      return false;
    }
  }

  Future<bool> logout(BuildContext context) async {
    try {
      // Obtener el token guardado
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        _showAlert(context, "Error", "No hay sesión activa");
        return false;
      }

      // Llamar al método logout del LoginService
      final result = await LoginService.logout(token: token);

      if (result['code'] == "00") {
        // Eliminar token de SharedPreferences
        await prefs.remove('api_token');
        return true;
      } else {
        _showAlert(context, "Error", result['message'] ?? "Error al cerrar sesión");
        return false;
      }
    } catch (e) {
      _showAlert(context, "Error", "No se pudo cerrar sesión.\n$e");
      return false;
    }
  }

  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
  }

  void _showAlert(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}