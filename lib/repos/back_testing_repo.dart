// backtest_repository.dart
// Handles the main POST /AT_BackTesting call.

import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'https://vtest.modernalgos.com';
const String _bearerToken =
    'Qy65p2Ahj/0ma3/Fbp6zD1YGuYuEQCN+tldas6iF7vVrrA3IkaA17Pz+hqXqycm8';

Map<String, String> get _headers => {
      'Authorization': 'Bearer $_bearerToken',
      'Content-Type': 'application/json',
      'Source': 'WEB',
    };

class BacktestResult {
  final bool success;
  final dynamic data;
  final String? error;

  const BacktestResult({required this.success, this.data, this.error});
}

Future<BacktestResult> runBacktest(Map<String, dynamic> payload) async {
  final uri = Uri.parse('$_baseUrl/AT_BackTesting');
  try {
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (resp.statusCode == 200) {
      return BacktestResult(success: true, data: jsonDecode(resp.body));
    }
    return BacktestResult(
        success: false,
        error: 'Server returned ${resp.statusCode}: ${resp.body}');
  } catch (e) {
    return BacktestResult(success: false, error: e.toString());
  }
}
