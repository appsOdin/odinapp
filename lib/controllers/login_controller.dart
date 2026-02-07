import 'package:flutter/material.dart';
import 'package:odinapp/Utlis/Constants.dart';
import 'package:odinapp/Utlis/CustomAlert.dart';
import 'package:odinapp/Utlis/CustomFieldValidator.dart';
import '../services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  Future<bool> login(BuildContext context) async {
    String user = usernameCtrl.text.trim();
    String pass = passwordCtrl.text.trim();

    /*
    *Logica para validar campos
    */
    final valid = await CustomFieldValidator.validateFields(
      context: context,
      fields: [
        FieldValidationDescriptor(
          controller: usernameCtrl,
          minLength: 8,
          fieldName: "Usuario",
        ),
        FieldValidationDescriptor(
          controller: passwordCtrl,
          minLength: 8,
          fieldName: "Contraseña",
        ),
      ],
    );
    if (valid) {
      try {
        // Llama al método login del LoginService
        final result = await LoginService.login(username: user, password: pass);

        if (result['code'] == Constants.successCode) {
          // Guardar token en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('api_token', result['data']['token']);

          CustomAlert.showAlert(context, "¡Éxito!", "Inicio de sesión correcto");
          return true;
        } else {
          // Muestra el mensaje de error del backend si existe
          CustomAlert.showAlert(
            context,
            "Error",
            result['message'] ?? Constants.errorMessage,
          );
          return false;
        }
      } catch (e) {
        CustomAlert.showAlert(context, "Error",  Constants.errorMessage);
        return false;
      }
    }
    return false;
  }

  Future<bool> logout(BuildContext context) async {
    try {
      // Obtener el token guardado
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        CustomAlert.showAlert(context, "Error", "No hay sesión activa");
        return false;
      }

      // Llamar al método logout del LoginService
      await LoginService.logout(token: token);
      // Eliminar token de SharedPreferences
      await prefs.remove('api_token');
      return true;
    } catch (e) {
      CustomAlert.showAlert(context, "Error",  Constants.errorMessage);
      return false;
    }
  }

  Future<bool> recover(BuildContext context) async {
    final valid = await CustomFieldValidator.validateFields(
      context: context,
      fields: [
        FieldValidationDescriptor(
          controller: emailCtrl,
          minLength: 8,
          fieldName: "Correo electrónico",
        ),
      ],
    );
    if (valid ) {
      try {
        // Llama al método recoverAccess del LoginService
        if (!CustomFieldValidator.isValidEmail(emailCtrl.text.trim())) {
          await CustomAlert.showAlert(
            context,
            "Datos incompletos",
            "Por favor, ingrese un correo electrónico válido",
          );
          return false;
        }
        final result = await LoginService.recoverAccess(email: emailCtrl.text.trim());

        if (result['code'] == Constants.successCode) {
          CustomAlert.showAlert(
            context,
            "¡Éxito!",
            "Instrucciones de recuperación enviadas a tu correo",
          );
          return true;
        } else {
          CustomAlert.showAlert(
            context,
            "Error",
            result['message'] ?? Constants.errorMessage,
          );
          return false;
        }
      } catch (e) {
        CustomAlert.showAlert(context, "Error",  Constants.errorMessage);
        return false;
      }
    }
    return false;
  }

  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    emailCtrl.dispose();
  }

}
