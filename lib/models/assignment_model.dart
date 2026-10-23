import 'package:flutter/foundation.dart';

import '../data/assignment_repository.dart';
import '../data/result.dart';
import '../domain/assignment.dart';

class AssignmentModel extends ChangeNotifier {
  final AssignmentRepository _repository;

  AssignmentModel(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Assignment> _assignments = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Assignment> get assignments => List.unmodifiable(_assignments);

  int get count => _assignments.length;

  int get completedCount => _assignments
      .where((assignment) => assignment.status == 'Completed')
      .length;

  Assignment? byId(int id) {
    for (final assignment in _assignments) {
      if (assignment.id == id) {
        return assignment;
      }
    }

    return null;
  }

  List<Assignment> forCourse(int courseId) {
    return List.unmodifiable(
      _assignments.where((assignment) => assignment.courseId == courseId),
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchAssignments();

    switch (result) {
      case Ok<List<Assignment>>(value: final value):
        _assignments = value;
        _error = null;

      case Err<List<Assignment>>(message: final message):
        _error = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> add(Assignment draft) async {
    final result = await _repository.createAssignment(draft);

    switch (result) {
      case Ok<Assignment>(value: final created):
        _assignments = [..._assignments, created];

        notifyListeners();
        return null;

      case Err<Assignment>(message: final message):
        return message;
    }
  }

  Future<String?> update(Assignment assignment) async {
    final result = await _repository.updateAssignment(assignment);

    switch (result) {
      case Ok<Assignment>(value: final updated):
        final index = _assignments.indexWhere((item) => item.id == updated.id);

        if (index != -1) {
          final items = [..._assignments];
          items[index] = updated;
          _assignments = items;

          notifyListeners();
        }

        return null;

      case Err<Assignment>(message: final message):
        return message;
    }
  }

  Future<String?> remove(int id) async {
    final result = await _repository.deleteAssignment(id);

    switch (result) {
      case Ok<void>():
        _assignments = _assignments
            .where((assignment) => assignment.id != id)
            .toList();

        notifyListeners();
        return null;

      case Err<void>(message: final message):
        return message;
    }
  }
}
