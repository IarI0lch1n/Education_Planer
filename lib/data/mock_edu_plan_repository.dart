import '../domain/assignment.dart';
import '../domain/course.dart';
import 'assignment_repository.dart';
import 'course_repository.dart';
import 'mock_data.dart';
import 'result.dart';

class MockEduPlanRepository implements CourseRepository, AssignmentRepository {
  final List<Course> _courses = List.of(mockCourses);
  final List<Assignment> _assignments = List.of(mockAssignments);

  int _nextAssignmentId = 1000;

  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);

  static const _networkError = 'Server is unavailable. Please try again.';

  Future<bool> _waitAndCheckError() async {
    await Future.delayed(_latency);

    return simulateError;
  }

  // --------------------------------------------------
  // Courses
  // --------------------------------------------------

  @override
  Future<Result<List<Course>>> fetchCourses() async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    return Ok(List.unmodifiable(_courses));
  }

  @override
  Future<Result<Course>> fetchCourseById(int id) async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    final index = _courses.indexWhere((course) => course.id == id);

    if (index == -1) {
      return const Err('Course does not exist.');
    }

    return Ok(_courses[index]);
  }

  // --------------------------------------------------
  // Assignments
  // --------------------------------------------------

  @override
  Future<Result<List<Assignment>>> fetchAssignments() async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    return Ok(List.unmodifiable(_assignments));
  }

  @override
  Future<Result<Assignment>> fetchAssignmentById(int id) async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    final index = _assignments.indexWhere((assignment) => assignment.id == id);

    if (index == -1) {
      return const Err('Assignment does not exist.');
    }

    return Ok(_assignments[index]);
  }

  @override
  Future<Result<Assignment>> createAssignment(Assignment assignment) async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    final createdAssignment = assignment.copyWith(id: _nextAssignmentId++);

    _assignments.add(createdAssignment);

    return Ok(createdAssignment);
  }

  @override
  Future<Result<Assignment>> updateAssignment(Assignment assignment) async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    final index = _assignments.indexWhere((item) => item.id == assignment.id);

    if (index == -1) {
      return const Err('Assignment does not exist.');
    }

    _assignments[index] = assignment;

    return Ok(assignment);
  }

  @override
  Future<Result<void>> deleteAssignment(int id) async {
    if (await _waitAndCheckError()) {
      return const Err(_networkError);
    }

    final index = _assignments.indexWhere((assignment) => assignment.id == id);

    if (index == -1) {
      return const Err('Assignment does not exist.');
    }

    _assignments.removeAt(index);

    return const Ok(null);
  }
}
