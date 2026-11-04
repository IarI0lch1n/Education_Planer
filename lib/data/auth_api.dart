import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;

  static const _timeout = Duration(seconds: 8);

  Future<Result<void>> register(String email, String password, String name) {
    return _post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Result<void>> login(String email, String password) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<void> logout() {
    return tokens.clear();
  }

  Future<Result<void>> _post(String path, Map<String, Object?> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return const Err('Ответ сервера имеет неверный формат');
      }

      final token = decoded['token'];

      if (token is! String || token.isEmpty) {
        return const Err('Ответ сервера имеет неверный формат');
      }

      await tokens.save(token);

      return const Ok<void>(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
