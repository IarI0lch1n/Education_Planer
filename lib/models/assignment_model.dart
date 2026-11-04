import 'package:flutter/foundation.dart';

import '../data/assignment_repository.dart';
import '../data/result.dart';
import '../domain/assignment.dart';

class AssignmentModel extends ChangeNotifier {
  AssignmentModel(this._repository);

  final AssignmentRepository _repository;

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;

  String? _error;
  String _search = '';

  int _page = 1;

  List<Assignment> _assignments = const [];

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  String? get error => _error;
  String get search => _search;

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

  Future<void> load({String? search}) async {
    if (search != null) {
      _search = search.trim();
    }

    _page = 1;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;

    notifyListeners();

    final result = await _repository.fetchAssignments(
      page: _page,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    switch (result) {
      case Ok<List<Assignment>>(value: final value):
        _assignments = value;

        _hasMore = value.length == _pageSize;

        _error = null;

      case Err<List<Assignment>>(message: final message):
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

    final result = await _repository.fetchAssignments(
      page: nextPage,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    switch (result) {
      case Ok<List<Assignment>>(value: final value):
        _assignments = [..._assignments, ...value];

        _page = nextPage;

        _hasMore = value.length == _pageSize;

      case Err<List<Assignment>>(message: final message):
        _error = message;
    }

    _isLoadingMore = false;

    notifyListeners();
  }

  Future<String?> add(Assignment draft) async {
    final result = await _repository.createAssignment(draft);

    switch (result) {
      case Ok<Assignment>():
        // Reload page 1 from the server so that
        // sorting/search/pagination stay consistent.
        await load();

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
