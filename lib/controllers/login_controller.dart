import 'package:flutter/material.dart';
import 'package:odinapp/Utlis/Constants.dart';
import '../services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

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

      if (result['code'] == Constants.successCode) {
        // Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', result['data']['token']);

        _showAlert(context, "¡Éxito!", "Inicio de sesión correcto");
        return true;
      } else {
        // Muestra el mensaje de error del backend si existe
        _showAlert(
          context,
          "Error",
          result['message'] ?? "Credenciales incorrectas",
        );
        return false;
      }
    } catch (e) {
      _showAlert(context, "Error", "Ha ocurrido un error.\n$e");
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
      await LoginService.logout(token: token);
      // Eliminar token de SharedPreferences
      await prefs.remove('api_token');
      return true;
    } catch (e) {
      _showAlert(context, "Error", "Ha ocurrido un error.\n$e");
      return false;
    }
  }

  Future<bool> recover(BuildContext context) async {  
    String email = emailCtrl.text.trim();

    if (email.isEmpty) {
      _showAlert(context, "Error", "Por favor, ingresa tu correo electrónico");
      return false;
    }

    try {
      // Llama al método recoverAccess del LoginService
      final result = await LoginService.recoverAccess(email: email);

      if (result['code'] == Constants.successCode) {
        _showAlert(context, "¡Éxito!", "Instrucciones de recuperación enviadas a tu correo");
        return true;
      } else {
        _showAlert(
          context,
          "Error",
          result['message'] ?? "No se pudo iniciar recuperación",
        );
        return false;
      }
    } catch (e) {
      _showAlert(context, "Error", "Ha ocurrido un error.\n$e");
      return false;
    }
  }



  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    emailCtrl.dispose();
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
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
