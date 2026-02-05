import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterController {
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  Future<bool> register(BuildContext context) async {
    // Validar todos los campos
    if (!_validateFields(context)) {
      return false;
    }

    try {
      // Llamar al método createUser del ApiService
      final result = await ApiService.createUser(
        identificacion: idCtrl.text.trim(),
        nombre: nameCtrl.text.trim(),
        apellidos: lastNameCtrl.text.trim(),
        usuario: usernameCtrl.text.trim(),
        contrasena: passwordCtrl.text.trim(),
        correo: emailCtrl.text.trim(),
      );

      if (result['code'] == "00") {
        _showAlert(context, "¡Éxito!", "Usuario registrado correctamente");
        return true;
      } else {
        _showAlert(context, "Error", result['message'] ?? "Error al registrar usuario");
        return false;
      }
    } catch (e) {
      _showAlert(context, "Error", "No se pudo conectar al servidor.\n$e");
      return false;
    }
  }

  bool _validateFields(BuildContext context) {
    // Validar que todos los campos estén llenos
    if (idCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese su identificación");
      return false;
    }

    if (nameCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese su nombre");
      return false;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese sus apellidos");
      return false;
    }

    if (usernameCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese un usuario");
      return false;
    }

    // Validar que el usuario tenga al menos 3 caracteres
    if (usernameCtrl.text.trim().length < 3) {
      _showAlert(context, "Error", "El usuario debe tener al menos 3 caracteres");
      return false;
    }

    if (passwordCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese una contraseña");
      return false;
    }

    // Validar que la contraseña tenga al menos 6 caracteres
    if (passwordCtrl.text.trim().length < 6) {
      _showAlert(context, "Error", "La contraseña debe tener al menos 6 caracteres");
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showAlert(context, "Error", "Por favor, ingrese su correo electrónico");
      return false;
    }

    // Validar formato de correo electrónico
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailCtrl.text.trim())) {
      _showAlert(context, "Error", "Por favor, ingrese un correo válido");
      return false;
    }

    return true;
  }

  void dispose() {
    idCtrl.dispose();
    nameCtrl.dispose();
    lastNameCtrl.dispose();
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
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
