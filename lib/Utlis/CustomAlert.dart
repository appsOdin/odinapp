import 'package:flutter/material.dart';

class CustomAlert {
   static Future<void> showAlert(BuildContext context, String title, String msg) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(msg),
        actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}