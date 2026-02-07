import 'package:flutter/material.dart';
import 'package:odinapp/Utlis/CustomAlert.dart';

class FieldValidationDescriptor {
  final TextEditingController controller;
  final int minLength;
  final String fieldName;
  final bool allowSpaces;

  FieldValidationDescriptor({
    required this.controller,
    required this.minLength,
    required this.fieldName,
    this.allowSpaces = false,
  });
}

class CustomFieldValidator {
  static Future<bool> validateFields({
    required BuildContext context,
    required List<FieldValidationDescriptor> fields,
  }) async {
    for (final descriptor in fields) {
      final text = descriptor.controller.text;
      if (text.trim().isEmpty) {
        await CustomAlert.showAlert(
          context,
          "Datos incompletos",
          "Por favor, ingrese ${descriptor.fieldName}",
        );
        return false;
      }
      if (!descriptor.allowSpaces && text.contains(' ')) {
        await CustomAlert.showAlert(
          context,
          "Datos incompletos",
          "${descriptor.fieldName} no debe contener espacios",
        );
        return false;
      }
      if (text.length < descriptor.minLength) {
        await CustomAlert.showAlert(
          context,
          "Datos incompletos",
          "${descriptor.fieldName} debe tener mínimo ${descriptor.minLength} caracteres",
        );
        return false;
      }
    }
    return true; // Todos los campos OK
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }
}
