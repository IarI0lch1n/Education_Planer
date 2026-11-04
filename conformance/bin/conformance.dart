import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final baseUrl = _argumentValue(
        args,
        '--base-url',
      ) ??
      'http://localhost:8080';

  final client = http.Client();

  try {
    stdout.writeln('');
    stdout.writeln('PAM Backend Conformance');
    stdout.writeln('Base URL: $baseUrl');
    stdout.writeln('');

    final context = TestContext(
      baseUrl: baseUrl,
      client: client,
    );

    final baseSuite = CheckSuite(
      'Template contract',
    );

    await _runBaseContract(
      baseSuite,
      context,
    );

    stdout.writeln('');

    if (baseSuite.allPassed) {
      stdout.writeln(
        'PASS — ${baseSuite.passed}/${baseSuite.total} checks passed',
      );
    } else {
      stdout.writeln(
        'FAIL — ${baseSuite.passed}/${baseSuite.total} checks passed',
      );
    }

    stdout.writeln('');
    stdout.writeln(
      'EduPlan extension',
    );
    stdout.writeln('');

    final eduPlanSuite = CheckSuite(
      'EduPlan extension',
    );

    await _runEduPlanContract(
      eduPlanSuite,
      context,
    );

    stdout.writeln('');

    if (eduPlanSuite.allPassed) {
      stdout.writeln(
        'EDUPLAN PASS — '
        '${eduPlanSuite.passed}/${eduPlanSuite.total} checks passed',
      );
    } else {
      stdout.writeln(
        'EDUPLAN FAIL — '
        '${eduPlanSuite.passed}/${eduPlanSuite.total} checks passed',
      );
    }

    stdout.writeln('');

    if (!baseSuite.allPassed ||
        !eduPlanSuite.allPassed) {
      exitCode = 1;
    }
  } finally {
    client.close();
  }
}

Future<void> _runBaseContract(
  CheckSuite suite,
  TestContext ctx,
) async {
  final stamp =
      DateTime.now().microsecondsSinceEpoch;

  final email =
      'conformance-$stamp@test.md';

  const password = 'parola123';

  const name = 'Conformance User';

  final secondEmail =
      'conformance-second-$stamp@test.md';

  http.Response? response;

  String token = '';
  String otherToken = '';

  int? userId;
  int? noteId;
  int? secondNoteId;
  int? fileId;

  //
  // 1. Health
  //

  await suite.check(
    'GET /health returns 200 and status=ok',
    () async {
      response = await ctx.client.get(
        ctx.uri('/health'),
      );

      final body = _jsonObject(response!);

      return response!.statusCode == 200 &&
          body?['status'] == 'ok';
    },
  );

  //
  // 2. Protected route without token
  //

  await suite.check(
    'GET /notes without token returns 401 UNAUTHORIZED',
    () async {
      response = await ctx.client.get(
        ctx.uri('/notes'),
      );

      return response!.statusCode == 401 &&
          _errorCode(response!) ==
              'UNAUTHORIZED';
    },
  );

  //
  // 3. Invalid registration
  //

  await suite.check(
    'Invalid registration returns 400 VALIDATION_ERROR',
    () async {
      response = await ctx.postJson(
        '/auth/register',
        {
          'email': 'invalid-email',
          'password': password,
          'name': name,
        },
      );

      return response!.statusCode == 400 &&
          _errorCode(response!) ==
              'VALIDATION_ERROR';
    },
  );

  //
  // Valid registration
  //

  response = await ctx.postJson(
    '/auth/register',
    {
      'email': email,
      'password': password,
      'name': name,
    },
  );

  await suite.check(
    'POST /auth/register returns 201',
    () {
      return response!.statusCode == 201;
    },
  );

  await suite.check(
    'Register response contains JWT token',
    () {
      final body = _jsonObject(response!);

      final value = body?['token'];

      return value is String &&
          value.isNotEmpty;
    },
  );

  await suite.check(
    'Register response contains correct user',
    () {
      final body = _jsonObject(response!);

      final user = body?['user'];

      if (user is! Map<String, dynamic>) {
        return false;
      }

      final id = user['id'];

      if (id is! int) {
        return false;
      }

      userId = id;

      final value = body?['token'];

      if (value is String) {
        token = value;
      }

      return user['email'] == email &&
          user['name'] == name;
    },
  );

  //
  // Duplicate registration
  //

  response = await ctx.postJson(
    '/auth/register',
    {
      'email': email,
      'password': password,
      'name': name,
    },
  );

  await suite.check(
    'Duplicate registration returns 409',
    () {
      return response!.statusCode == 409;
    },
  );

  await suite.check(
    'Duplicate registration returns EMAIL_TAKEN',
    () {
      return _errorCode(response!) ==
          'EMAIL_TAKEN';
    },
  );

  //
  // Wrong login
  //

  response = await ctx.postJson(
    '/auth/login',
    {
      'email': email,
      'password': 'wrong-password',
    },
  );

  await suite.check(
    'Wrong password returns 401 UNAUTHORIZED',
    () {
      return response!.statusCode == 401 &&
          _errorCode(response!) ==
              'UNAUTHORIZED';
    },
  );

  //
  // Correct login
  //

  response = await ctx.postJson(
    '/auth/login',
    {
      'email': email,
      'password': password,
    },
  );

  await suite.check(
    'POST /auth/login returns 200',
    () {
      return response!.statusCode == 200;
    },
  );

  await suite.check(
    'Login response contains JWT token',
    () {
      final body = _jsonObject(response!);

      final value = body?['token'];

      if (value is! String ||
          value.isEmpty) {
        return false;
      }

      token = value;

      return true;
    },
  );

  //
  // /me
  //

  response = await ctx.client.get(
    ctx.uri('/me'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'GET /me returns 200',
    () {
      return response!.statusCode == 200;
    },
  );

  await suite.check(
    'GET /me returns authenticated user',
    () {
      final body = _jsonObject(response!);

      return body?['id'] == userId &&
          body?['email'] == email &&
          body?['name'] == name;
    },
  );

  //
  // Notes list
  //

  response = await ctx.client.get(
    ctx.uri('/notes'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'GET /notes returns 200',
    () {
      return response!.statusCode == 200;
    },
  );

  await suite.check(
    'Notes use pagination envelope',
    () {
      final body = _jsonObject(response!);

      return body?['items'] is List &&
          body?['page'] == 1 &&
          body?['limit'] == 20 &&
          body?['total'] is int;
    },
  );

  //
  // Invalid note
  //

  response = await ctx.postJson(
    '/notes',
    {
      'content': 'Missing title',
    },
    token: token,
  );

  await suite.check(
    'Invalid note returns 400 VALIDATION_ERROR',
    () {
      return response!.statusCode == 400 &&
          _errorCode(response!) ==
              'VALIDATION_ERROR';
    },
  );

  //
  // Create note
  //

  final noteTitle =
      'Conformance note $stamp';

  final noteContent =
      'Initial conformance content';

  response = await ctx.postJson(
    '/notes',
    {
      'title': noteTitle,
      'content': noteContent,
    },
    token: token,
  );

  await suite.check(
    'POST /notes returns 201',
    () {
      return response!.statusCode == 201;
    },
  );

  await suite.check(
    'Created note has server id and expected fields',
    () {
      final body = _jsonObject(response!);

      final id = body?['id'];

      if (id is! int || id <= 0) {
        return false;
      }

      noteId = id;

      return body?['title'] == noteTitle &&
          body?['content'] ==
              noteContent &&
          body?['createdAt'] is String;
    },
  );

  //
  // Get note
  //

  response = await ctx.client.get(
    ctx.uri('/notes/$noteId'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'GET /notes/{id} returns created note',
    () {
      final body = _jsonObject(response!);

      return response!.statusCode == 200 &&
          body?['id'] == noteId &&
          body?['title'] == noteTitle &&
          body?['content'] ==
              noteContent;
    },
  );

  //
  // Update note
  //

  final updatedTitle =
      'Updated conformance $stamp';

  final updatedContent =
      'Updated content';

  response = await ctx.putJson(
    '/notes/$noteId',
    {
      'title': updatedTitle,
      'content': updatedContent,
    },
    token: token,
  );

  await suite.check(
    'PUT /notes/{id} returns 200',
    () {
      return response!.statusCode == 200;
    },
  );

  await suite.check(
    'PUT /notes/{id} persists updated fields',
    () {
      final body = _jsonObject(response!);

      return body?['id'] == noteId &&
          body?['title'] ==
              updatedTitle &&
          body?['content'] ==
              updatedContent;
    },
  );

  //
  // Second note for pagination
  //

  response = await ctx.postJson(
    '/notes',
    {
      'title':
          'Second conformance note $stamp',
      'content': 'Second note',
    },
    token: token,
  );

  await suite.check(
    'Second note can be created',
    () {
      final body = _jsonObject(response!);

      final id = body?['id'];

      if (response!.statusCode != 201 ||
          id is! int) {
        return false;
      }

      secondNoteId = id;

      return true;
    },
  );

  //
  // Search
  //

  response = await ctx.client.get(
    ctx.uri(
      '/notes',
      {
        'search': 'Updated conformance $stamp',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Server-side note search returns 200',
    () {
      return response!.statusCode == 200;
    },
  );

  await suite.check(
    'Server-side note search finds expected note',
    () {
      final body = _jsonObject(response!);

      final items = body?['items'];

      if (items is! List) {
        return false;
      }

      return items.any(
        (item) =>
            item is Map<String, dynamic> &&
            item['id'] == noteId,
      );
    },
  );

  //
  // Pagination
  //

  final pageOneResponse =
      await ctx.client.get(
    ctx.uri(
      '/notes',
      {
        'page': '1',
        'limit': '1',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Pagination page=1 limit=1 is honored',
    () {
      final body =
          _jsonObject(pageOneResponse);

      final items = body?['items'];

      return pageOneResponse.statusCode ==
              200 &&
          body?['page'] == 1 &&
          body?['limit'] == 1 &&
          body?['total'] is int &&
          (body?['total'] as int) >= 2 &&
          items is List &&
          items.length == 1;
    },
  );

  final pageTwoResponse =
      await ctx.client.get(
    ctx.uri(
      '/notes',
      {
        'page': '2',
        'limit': '1',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Pagination page=2 returns next item',
    () {
      final first =
          _jsonObject(pageOneResponse);

      final second =
          _jsonObject(pageTwoResponse);

      final firstItems =
          first?['items'];

      final secondItems =
          second?['items'];

      if (pageTwoResponse.statusCode !=
              200 ||
          second?['page'] != 2 ||
          second?['limit'] != 1 ||
          firstItems is! List ||
          secondItems is! List ||
          firstItems.length != 1 ||
          secondItems.length != 1) {
        return false;
      }

      final firstId =
          (firstItems.first
                  as Map<String, dynamic>)['id'];

      final secondId =
          (secondItems.first
                  as Map<String, dynamic>)['id'];

      return firstId != secondId;
    },
  );

  //
  // User isolation
  //

  response = await ctx.postJson(
    '/auth/register',
    {
      'email': secondEmail,
      'password': password,
      'name': 'Second User',
    },
  );

  await suite.check(
    'Second user can register',
    () {
      final body = _jsonObject(response!);

      final value = body?['token'];

      if (response!.statusCode != 201 ||
          value is! String) {
        return false;
      }

      otherToken = value;

      return true;
    },
  );

  response = await ctx.client.get(
    ctx.uri('/notes/$noteId'),
    headers:
        ctx.authHeaders(otherToken),
  );

  await suite.check(
    'Another user sees foreign note as 404 NOT_FOUND',
    () {
      return response!.statusCode == 404 &&
          _errorCode(response!) ==
              'NOT_FOUND';
    },
  );

  //
  // Delete
  //

  response = await ctx.client.delete(
    ctx.uri('/notes/$noteId'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'DELETE /notes/{id} returns empty 204',
    () {
      return response!.statusCode == 204 &&
          response!.bodyBytes.isEmpty;
    },
  );

  response = await ctx.client.get(
    ctx.uri('/notes/$noteId'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Deleted note returns 404 NOT_FOUND',
    () {
      return response!.statusCode == 404 &&
          _errorCode(response!) ==
              'NOT_FOUND';
    },
  );

  //
  // Standard 404 envelope
  //

  response = await ctx.client.get(
    ctx.uri(
      '/definitely-does-not-exist-$stamp',
    ),
  );

  await suite.check(
    'Unknown route returns standard 404 NOT_FOUND envelope',
    () {
      return response!.statusCode == 404 &&
          _errorCode(response!) ==
              'NOT_FOUND';
    },
  );

  //
  // Files
  //

  response = await ctx.client.post(
    ctx.uri('/files'),
  );

  await suite.check(
    'POST /files without token returns 401 UNAUTHORIZED',
    () {
      return response!.statusCode == 401 &&
          _errorCode(response!) ==
              'UNAUTHORIZED';
    },
  );

  final wrongMultipart =
      http.MultipartRequest(
    'POST',
    ctx.uri('/files'),
  );

  wrongMultipart.headers.addAll(
    ctx.authHeaders(token),
  );

  wrongMultipart.fields['wrong'] =
      'not a file';

  final wrongMultipartResponse =
      await http.Response.fromStream(
    await wrongMultipart.send(),
  );

  await suite.check(
    'Multipart without field "file" returns 400 VALIDATION_ERROR',
    () {
      return wrongMultipartResponse
                  .statusCode ==
              400 &&
          _errorCode(
                wrongMultipartResponse,
              ) ==
              'VALIDATION_ERROR';
    },
  );

  final fileBytes = utf8.encode(
    'EduPlan conformance file $stamp',
  );

  final upload =
      http.MultipartRequest(
    'POST',
    ctx.uri('/files'),
  );

  upload.headers.addAll(
    ctx.authHeaders(token),
  );

  upload.files.add(
    http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: 'conformance.txt',
    ),
  );

  final uploadResponse =
      await http.Response.fromStream(
    await upload.send(),
  );

  await suite.check(
    'Valid multipart upload returns 201',
    () {
      return uploadResponse.statusCode ==
          201;
    },
  );

  await suite.check(
    'Upload response contains correct metadata',
    () {
      final body =
          _jsonObject(uploadResponse);

      final id = body?['id'];

      if (id is! int) {
        return false;
      }

      fileId = id;

      return body?['url'] ==
              '/files/$id' &&
          body?['name'] ==
              'conformance.txt' &&
          body?['size'] ==
              fileBytes.length &&
          body?['mimeType'] is String;
    },
  );

  final downloadResponse =
      await ctx.client.get(
    ctx.uri('/files/$fileId'),
  );

  await suite.check(
    'Uploaded file can be downloaded byte-for-byte',
    () {
      return downloadResponse
                  .statusCode ==
              200 &&
          _bytesEqual(
            downloadResponse.bodyBytes,
            fileBytes,
          );
    },
  );

  await suite.check(
    'File download includes security headers',
    () {
      final headers =
          downloadResponse.headers;

      return headers[
                  'x-content-type-options'] ==
              'nosniff' &&
          (headers['content-disposition'] ??
                  '')
              .contains('attachment') &&
          headers[
                  'content-security-policy'] ==
              "default-src 'none'; sandbox";
    },
  );

  //
  // Cleanup the second note.
  // Cleanup is intentionally not counted as a check.
  //

  if (secondNoteId != null &&
      token.isNotEmpty) {
    await ctx.client.delete(
      ctx.uri('/notes/$secondNoteId'),
      headers: ctx.authHeaders(token),
    );
  }

  if (suite.total != 37) {
    throw StateError(
      'Base suite must contain exactly '
      '37 checks, but contains ${suite.total}.',
    );
  }

  ctx.primaryToken = token;
}

Future<void> _runEduPlanContract(
  CheckSuite suite,
  TestContext ctx,
) async {
  final stamp =
      DateTime.now().microsecondsSinceEpoch;

  final token = ctx.primaryToken;

  if (token.isEmpty) {
    stdout.writeln(
      'Cannot run EduPlan extension tests: '
      'base authentication did not produce a token.',
    );

    return;
  }

  http.Response? response;

  int? courseId;
  int? assignmentId;

  final courseName =
      'Conformance Course $stamp';

  //
  // Courses
  //

  await suite.check(
    'GET /courses without token returns 401',
    () async {
      final res = await ctx.client.get(
        ctx.uri('/courses'),
      );

      return res.statusCode == 401 &&
          _errorCode(res) ==
              'UNAUTHORIZED';
    },
  );

  await suite.check(
    'Invalid course returns 400 VALIDATION_ERROR',
    () async {
      final res = await ctx.postJson(
        '/courses',
        {
          'name': courseName,
        },
        token: token,
      );

      return res.statusCode == 400 &&
          _errorCode(res) ==
              'VALIDATION_ERROR';
    },
  );

  response = await ctx.postJson(
    '/courses',
    {
      'name': courseName,
      'teacher': 'Teacher Test',
      'room': 'T-101',
      'weekday': 'Monday',
      'startTime': '10:00',
    },
    token: token,
  );

  await suite.check(
    'POST /courses returns 201',
    () {
      return response!.statusCode == 201;
    },
  );

  await suite.check(
    'Created course has server id and correct fields',
    () {
      final body = _jsonObject(response!);

      final id = body?['id'];

      if (id is! int) {
        return false;
      }

      courseId = id;

      return body?['name'] ==
              courseName &&
          body?['teacher'] ==
              'Teacher Test' &&
          body?['room'] == 'T-101' &&
          body?['weekday'] ==
              'Monday' &&
          body?['startTime'] ==
              '10:00';
    },
  );

  response = await ctx.client.get(
    ctx.uri(
      '/courses',
      {
        'page': '1',
        'limit': '20',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'GET /courses returns pagination envelope',
    () {
      final body = _jsonObject(response!);

      return response!.statusCode == 200 &&
          body?['items'] is List &&
          body?['page'] == 1 &&
          body?['limit'] == 20 &&
          body?['total'] is int;
    },
  );

  response = await ctx.client.get(
    ctx.uri(
      '/courses',
      {
        'search': courseName,
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Course server-side search finds created course',
    () {
      final body = _jsonObject(response!);

      final items = body?['items'];

      return response!.statusCode == 200 &&
          items is List &&
          items.any(
            (item) =>
                item
                    is Map<String,
                        dynamic> &&
                item['id'] ==
                    courseId,
          );
    },
  );

  response = await ctx.putJson(
    '/courses/$courseId',
    {
      'name': '$courseName Updated',
      'teacher': 'Teacher Updated',
      'room': 'T-202',
      'weekday': 'Tuesday',
      'startTime': '12:00',
    },
    token: token,
  );

  await suite.check(
    'PUT /courses/{id} updates course',
    () {
      final body = _jsonObject(response!);

      return response!.statusCode == 200 &&
          body?['id'] == courseId &&
          body?['name'] ==
              '$courseName Updated' &&
          body?['weekday'] ==
              'Tuesday';
    },
  );

  //
  // Assignments
  //

  await suite.check(
    'Assignment with missing course returns 400',
    () async {
      final res = await ctx.postJson(
        '/assignments',
        {
          'courseId': 999999999,
          'title': 'Invalid assignment',
          'deadline': '30.12.2026',
          'status': 'New',
          'priority': 'High',
        },
        token: token,
      );

      return res.statusCode == 400 &&
          _errorCode(res) ==
              'VALIDATION_ERROR';
    },
  );

  response = await ctx.postJson(
    '/assignments',
    {
      'courseId': courseId,
      'title':
          'Conformance Assignment $stamp',
      'deadline': '30.12.2026',
      'status': 'New',
      'priority': 'High',
    },
    token: token,
  );

  await suite.check(
    'POST /assignments returns 201',
    () {
      return response!.statusCode == 201;
    },
  );

  await suite.check(
    'Created assignment has server id and correct fields',
    () {
      final body = _jsonObject(response!);

      final id = body?['id'];

      if (id is! int) {
        return false;
      }

      assignmentId = id;

      return body?['courseId'] ==
              courseId &&
          body?['status'] == 'New' &&
          body?['priority'] ==
              'High';
    },
  );

  response = await ctx.client.get(
    ctx.uri(
      '/assignments',
      {
        'search':
            'Conformance Assignment $stamp',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Assignment server-side search finds created assignment',
    () {
      final body = _jsonObject(response!);

      final items = body?['items'];

      return response!.statusCode == 200 &&
          items is List &&
          items.any(
            (item) =>
                item
                    is Map<String,
                        dynamic> &&
                item['id'] ==
                    assignmentId,
          );
    },
  );

  response = await ctx.client.get(
    ctx.uri(
      '/assignments',
      {
        'page': '1',
        'limit': '1',
      },
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Assignments support page and limit parameters',
    () {
      final body = _jsonObject(response!);

      final items = body?['items'];

      return response!.statusCode == 200 &&
          body?['page'] == 1 &&
          body?['limit'] == 1 &&
          body?['total'] is int &&
          items is List &&
          items.length <= 1;
    },
  );

  response = await ctx.putJson(
    '/assignments/$assignmentId',
    {
      'courseId': courseId,
      'title':
          'Conformance Assignment Updated $stamp',
      'deadline': '31.12.2026',
      'status': 'In progress',
      'priority': 'Medium',
    },
    token: token,
  );

  await suite.check(
    'PUT /assignments/{id} updates assignment',
    () {
      final body = _jsonObject(response!);

      return response!.statusCode == 200 &&
          body?['id'] ==
              assignmentId &&
          body?['status'] ==
              'In progress' &&
          body?['priority'] ==
              'Medium';
    },
  );

  response = await ctx.client.delete(
    ctx.uri(
      '/assignments/$assignmentId',
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'DELETE /assignments/{id} returns 204',
    () {
      return response!.statusCode == 204 &&
          response!.bodyBytes.isEmpty;
    },
  );

  response = await ctx.client.get(
    ctx.uri(
      '/assignments/$assignmentId',
    ),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Deleted assignment returns 404',
    () {
      return response!.statusCode == 404 &&
          _errorCode(response!) ==
              'NOT_FOUND';
    },
  );

  response = await ctx.client.delete(
    ctx.uri('/courses/$courseId'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'DELETE /courses/{id} returns 204',
    () {
      return response!.statusCode == 204 &&
          response!.bodyBytes.isEmpty;
    },
  );

  response = await ctx.client.get(
    ctx.uri('/courses/$courseId'),
    headers: ctx.authHeaders(token),
  );

  await suite.check(
    'Deleted course returns 404',
    () {
      return response!.statusCode == 404 &&
          _errorCode(response!) ==
              'NOT_FOUND';
    },
  );

  if (suite.total != 17) {
    throw StateError(
        'EduPlan suite must contain exactly '
        '17 checks, but contains ${suite.total}.',
    );
    }
}

class TestContext {
  TestContext({
    required this.baseUrl,
    required this.client,
  });

  final String baseUrl;
  final http.Client client;

  String primaryToken = '';

  Uri uri(
    String path, [
    Map<String, String>? query,
  ]) {
    return Uri.parse(
      '$baseUrl$path',
    ).replace(
      queryParameters: query,
    );
  }

  Map<String, String> authHeaders(
    String token,
  ) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) {
    return client.post(
      uri(path),
      headers: {
        'Content-Type':
            'application/json',
        if (token != null)
          'Authorization':
              'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> putJson(
    String path,
    Map<String, Object?> body, {
    required String token,
  }) {
    return client.put(
      uri(path),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}

class CheckSuite {
  CheckSuite(this.name);

  final String name;

  int passed = 0;
  int total = 0;

  bool get allPassed =>
      passed == total;

  Future<void> check(
    String description,
    FutureOr<bool> Function() callback,
  ) async {
    total++;

    try {
      final result =
          await callback();

      if (result) {
        passed++;

        stdout.writeln(
          '✓ ${total.toString().padLeft(2)}. '
          '$description',
        );
      } else {
        stdout.writeln(
          '✗ ${total.toString().padLeft(2)}. '
          '$description',
        );
      }
    } catch (error) {
      stdout.writeln(
        '✗ ${total.toString().padLeft(2)}. '
        '$description',
      );

      stdout.writeln(
        '    $error',
      );
    }
  }
}

Map<String, dynamic>? _jsonObject(
  http.Response response,
) {
  try {
    final decoded =
        jsonDecode(response.body);

    if (decoded
        is Map<String, dynamic>) {
      return decoded;
    }

    return null;
  } catch (_) {
    return null;
  }
}

String? _errorCode(
  http.Response response,
) {
  final body =
      _jsonObject(response);

  final error =
      body?['error'];

  if (error
      is! Map<String, dynamic>) {
    return null;
  }

  final code =
      error['code'];

  return code is String
      ? code
      : null;
}

bool _bytesEqual(
  List<int> a,
  List<int> b,
) {
  if (a.length != b.length) {
    return false;
  }

  for (var i = 0;
      i < a.length;
      i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }

  return true;
}

String? _argumentValue(
  List<String> args,
  String name,
) {
  for (var i = 0;
      i < args.length;
      i++) {
    final argument = args[i];

    if (argument.startsWith(
      '$name=',
    )) {
      return argument.substring(
        name.length + 1,
      );
    }

    if (argument == name &&
        i + 1 < args.length) {
      return args[i + 1];
    }
  }

  return null;
}