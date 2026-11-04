import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/assignment.dart';
import 'api_message.dart';
import 'assignment_repository.dart';
import 'result.dart';
import 'token_store.dart';

class HttpAssignmentRepository implements AssignmentRepository {
  HttpAssignmentRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async {
    final token = await tokens.read();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<String> _sessionDied() async {
    await tokens.clear();

    onUnauthorized?.call();

    return 'Сессия истекла — войдите снова';
  }

  @override
  Future<Result<List<Assignment>>> fetchAssignments() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/assignments'), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final items = data['items'] as List<dynamic>;

      final assignments = items
          .map((item) => Assignment.fromJson(item as Map<String, dynamic>))
          .toList();

      return Ok(assignments);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    }
  }

  @override
  Future<Result<Assignment>> fetchAssignmentById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/assignments/$id'), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Ok(Assignment.fromJson(data));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    }
  }

  @override
  Future<Result<Assignment>> createAssignment(Assignment assignment) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/assignments'),
            headers: await _headers(),
            body: jsonEncode(assignment.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Ok(Assignment.fromJson(data));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    }
  }

  @override
  Future<Result<Assignment>> updateAssignment(Assignment assignment) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/assignments/${assignment.id}'),
            headers: await _headers(),
            body: jsonEncode(assignment.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Ok(Assignment.fromJson(data));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    }
  }

  @override
  Future<Result<void>> deleteAssignment(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/assignments/$id'),
            headers: await _headers(),
          )
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 204) {
        return Err(apiMessage(response));
      }

      // Important:
      // 204 has no body, so do NOT jsonDecode it.
      return const Ok<void>(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    }
  }
}
