import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/assignment_card.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            context.push('/assignments/new');
        },
        child: const Icon(Icons.add),
        ),
      body: ListView(
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
            '${mockAssignments.length} assignments',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Status',
            style: theme.textTheme.titleSmall,
          ),
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

          Text(
            'Deadline',
            style: theme.textTheme.titleSmall,
          ),
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

          ...mockAssignments.map(
            (assignment) {
              final course = mockCourses.firstWhere(
                (course) => course.id == assignment.courseId,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AssignmentCard(
                  assignment: assignment,
                  courseName: course.name,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}