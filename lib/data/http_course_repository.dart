import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/course.dart';
import 'api_message.dart';
import 'course_repository.dart';
import 'result.dart';
import 'token_store.dart';

class HttpCourseRepository implements CourseRepository {
  HttpCourseRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

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
  Future<Result<List<Course>>> fetchCourses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/courses'), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final items = data['items'] as List<dynamic>;

      final courses = items
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();

      return Ok(courses);
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
  Future<Result<Course>> fetchCourseById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/courses/$id'), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Ok(Course.fromJson(data));
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
