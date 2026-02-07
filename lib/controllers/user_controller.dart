import 'package:flutter/material.dart';
import 'package:odinapp/Utlis/Constants.dart';
import 'package:odinapp/Utlis/CustomAlert.dart';
import 'package:odinapp/Utlis/CustomFieldValidator.dart';
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
    final isValid = await CustomFieldValidator.validateFields(
      context: context,
      fields: [
        FieldValidationDescriptor(
          controller: idCtrl,
          minLength: 9,
          fieldName: "Identificación",
        ),
        FieldValidationDescriptor(
          controller: nameCtrl,
          minLength: 2,
          fieldName: "Nombre",
          allowSpaces: true, // Permitir espacios en el nombre
        ),
        FieldValidationDescriptor(
          controller: lastNameCtrl,
          minLength: 2,
          fieldName: "Apellido",
          allowSpaces: true, // Permitir espacios en el apellido
        ),
        FieldValidationDescriptor(
          controller: usernameCtrl,
          minLength: 6,
          fieldName: "Usuario",
        ),
        FieldValidationDescriptor(
          controller: passwordCtrl,
          minLength: 8,
          fieldName: "Contraseña",
        ),
        FieldValidationDescriptor(
          controller: emailCtrl,
          minLength: 8,
          fieldName: "Correo electrónico",
        ),
      ],
    );
    if (isValid) {
      if (!CustomFieldValidator.isValidEmail(emailCtrl.text.trim())) {
        await CustomAlert.showAlert(
          context,
          "Datos incompletos",
          "Por favor, ingrese un correo electrónico válido",
        );
        return false;
      }
      try {
        // Llamar al método createUser del UserService
        final result = await UserService.createSuscriber(
          id: idCtrl.text.trim(),
          name: nameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          username: usernameCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
          email: emailCtrl.text.trim(),
        );

        if (result['code'] == Constants.successCode) {
          await CustomAlert.showAlert(
            context,
            "¡Éxito!",
            "Usuario registrado correctamente",
          );
          return true;
        } else {
          await CustomAlert.showAlert(
            context,
            "Error",
            result['message'] ?? Constants.errorMessage,
          );
          return false;
        }
      } catch (e) {
        await CustomAlert.showAlert(context, "Error", Constants.errorMessage);
        return false;
      }
    } else {
      return false; // Si la validación de campos falla, no continuar
    }
  }

  void dispose() {
    idCtrl.dispose();
    nameCtrl.dispose();
    lastNameCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    emailCtrl.dispose();
  }
}
