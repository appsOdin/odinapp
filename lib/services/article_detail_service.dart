import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:odinapp/Utlis/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_detail_model.dart';

class ArticleDetailService {
  static const String _baseUrl = Constants.apiBaseUrl;
  static const String _endpoint = '$_baseUrl/Article/GetArticleDetail';

  Future<ArticleDetail> getArticleDetail({required String articleId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesion activa.');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'search': articleId}),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el detalle del articulo.');
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final String code = (decoded['code'] ?? '').toString();

    if (code != Constants.successCode) {
      final message = (decoded['message'] ?? Constants.errorMessage).toString();
      throw Exception(message);
    }

    final dynamic data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Formato de respuesta invalido.');
    }

    return ArticleDetail.fromApiData(data);
  }
}
