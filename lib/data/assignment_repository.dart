import '../domain/assignment.dart';
import 'result.dart';

abstract class AssignmentRepository {
  Future<Result<List<Assignment>>> fetchAssignments({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<Result<Assignment>> fetchAssignmentById(int id);

  Future<Result<Assignment>> createAssignment(Assignment assignment);

  Future<Result<Assignment>> updateAssignment(Assignment assignment);

  Future<Result<void>> deleteAssignment(int id);
}
