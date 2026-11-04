import '../domain/course.dart';
import 'result.dart';

abstract class CourseRepository {
  Future<Result<List<Course>>> fetchCourses({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<Result<Course>> fetchCourseById(int id);
}
