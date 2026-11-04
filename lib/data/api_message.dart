import 'dart:convert';

import 'package:http/http.dart' as http;

String apiMessage(http.Response response) {
  try {
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      return 'Ошибка сервера (${response.statusCode})';
    }

    final error = decoded['error'];

    if (error is! Map<String, dynamic>) {
      return 'Ошибка сервера (${response.statusCode})';
    }

    final code = error['code'];

    if (code is! String) {
      return 'Ошибка сервера (${response.statusCode})';
    }

    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' => 'Неверный email или пароль',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    return 'Ошибка сервера (${response.statusCode})';
  } on TypeError {
    return 'Ошибка сервера (${response.statusCode})';
  }
}
