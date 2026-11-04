import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../data/result.dart';
import '../domain/course.dart';

class CourseModel extends ChangeNotifier {
  CourseModel(this._repository);

  final CourseRepository _repository;

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;

  String? _error;
  String _search = '';

  int _page = 1;

  List<Course> _courses = const [];

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  String? get error => _error;
  String get search => _search;

  List<Course> get courses => List.unmodifiable(_courses);

  Course? byId(int id) {
    for (final course in _courses) {
      if (course.id == id) {
        return course;
      }
    }

    return null;
  }

  Future<void> load({String? search}) async {
    if (search != null) {
      _search = search.trim();
    }

    _page = 1;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;

    notifyListeners();

    final result = await _repository.fetchCourses(
      page: _page,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    switch (result) {
      case Ok<List<Course>>(value: final value):
        _courses = value;
        _hasMore = value.length == _pageSize;
        _error = null;

      case Err<List<Course>>(message: final message):
        _hasMore = false;
        _error = message;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    _error = null;

    notifyListeners();

    final nextPage = _page + 1;

    final result = await _repository.fetchCourses(
      page: nextPage,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    switch (result) {
      case Ok<List<Course>>(value: final value):
        _courses = [..._courses, ...value];

        _page = nextPage;

        _hasMore = value.length == _pageSize;

      case Err<List<Course>>(message: final message):
        _error = message;
    }

    _isLoadingMore = false;

    notifyListeners();
  }
}
