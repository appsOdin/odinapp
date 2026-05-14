import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odinapp/Utlis/Constants.dart';
import 'package:odinapp/Utlis/CustomAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';

class ArticleService {
  static const String _baseUrl = Constants.apiBaseUrl;
  static const String _endpoint = '$_baseUrl/Article/GetAllArticles';

  Future<List<Article>> getAllArticles(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null || token.isEmpty) {
      await CustomAlert.showAlert(context, 'Error', 'No hay sesión activa');
      throw Exception('Token no disponible');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'search': ""}),
    );

    if (response.statusCode != 200) {
      await CustomAlert.showAlert(
        context,
        'Error',
        'No se pudieron obtener los artículos.',
      );
      throw Exception('Error HTTP: ${response.statusCode}');
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final dynamic data = decoded['data'];

    if (data is! List) {
      throw Exception('Formato de respuesta inválido');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Article.fromJson)
        .toList(growable: false);
  }
}
