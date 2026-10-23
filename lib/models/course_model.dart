import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../data/result.dart';
import '../domain/course.dart';

class CourseModel extends ChangeNotifier {
  final CourseRepository _repository;

  CourseModel(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Course> _courses = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Course> get courses => List.unmodifiable(_courses);

  Course? byId(int id) {
    for (final course in _courses) {
      if (course.id == id) {
        return course;
      }
    }

    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchCourses();

    switch (result) {
      case Ok<List<Course>>(value: final value):
        _courses = value;
        _error = null;

      case Err<List<Course>>(message: final message):
        _error = message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
