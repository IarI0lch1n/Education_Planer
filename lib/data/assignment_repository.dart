import '../domain/assignment.dart';
import 'result.dart';

abstract class AssignmentRepository {
  Future<Result<List<Assignment>>> fetchAssignments();

  Future<Result<Assignment>> fetchAssignmentById(int id);

  Future<Result<Assignment>> createAssignment(Assignment assignment);

  Future<Result<Assignment>> updateAssignment(Assignment assignment);

  Future<Result<void>> deleteAssignment(int id);
}
