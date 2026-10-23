import '../domain/course.dart';
import 'result.dart';

abstract class CourseRepository {
  Future<Result<List<Course>>> fetchCourses();

  Future<Result<Course>> fetchCourseById(int id);
}
