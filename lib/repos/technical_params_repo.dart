import 'dart:convert';
import 'package:backtesting_app/models/technical_param_model.dart';
import 'package:http/http.dart' as http;

class TechnicalRepository {
  static const String _baseUrl = 'https://vtest.modernalgos.com';
  static const String _bearerToken =
      'Qy65p2Ahj/0ma3/Fbp6zD1YGuYuEQCN+tldas6iF7vVrrA3IkaA17Pz+hqXqycm8';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json',
      };

  Future<TechnicalParams> fetchTechnicalParams(String indicator) async {
    final url = Uri.parse('$_baseUrl/technical_param');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "indicator": indicator,
      }),
    );

    if (response.statusCode == 200) {
      print("successss");
      return TechnicalParams.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }
}
