import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../widgets/assignment_card.dart';
import '../widgets/error_view.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignmentModel = context.watch<AssignmentModel>();
    final courseModel = context.watch<CourseModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/assignments/new');
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context, assignmentModel, courseModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AssignmentModel assignmentModel,
    CourseModel courseModel,
  ) {
    if (assignmentModel.isLoading || courseModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assignmentModel.error != null) {
      return ErrorView(
        message: assignmentModel.error!,
        onRetry: () {
          context.read<AssignmentModel>().load();
        },
      );
    }

    if (courseModel.error != null) {
      return ErrorView(
        message: courseModel.error!,
        onRetry: () {
          context.read<CourseModel>().load();
        },
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'My assignments',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          '${assignmentModel.assignments.length} assignments',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        Text('Status', style: theme.textTheme.titleSmall),

        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('New'),
                selected: false,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('In progress'),
                selected: false,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Completed'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text('Deadline', style: theme.textTheme.titleSmall),

        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All dates'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('This week'),
                selected: false,
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Later'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ...assignmentModel.assignments.map((assignment) {
          final course = courseModel.byId(assignment.courseId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AssignmentCard(
              assignment: assignment,
              courseName: course?.name ?? 'Unknown course',
            ),
          );
        }),
      ],
    );
  }
}
