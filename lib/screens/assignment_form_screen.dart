import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class AssignmentFormScreen extends StatelessWidget {
  const AssignmentFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New assignment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Assignment details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in the information below.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Assignment title',
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
          ),

          const SizedBox(height: 16),

          DropdownMenu<int>(
            width: double.infinity,
            label: const Text('Course'),
            leadingIcon: const Icon(Icons.menu_book_outlined),
            dropdownMenuEntries: mockCourses
                .map(
                  (course) => DropdownMenuEntry<int>(
                    value: course.id,
                    label: course.name,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Deadline',
              hintText: 'Select deadline',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          const SizedBox(height: 16),

          DropdownMenu<String>(
            width: double.infinity,
            label: const Text('Priority'),
            leadingIcon: const Icon(Icons.flag_outlined),
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'Low',
                label: 'Low',
              ),
              DropdownMenuEntry(
                value: 'Medium',
                label: 'Medium',
              ),
              DropdownMenuEntry(
                value: 'High',
                label: 'High',
              ),
            ],
          ),

          const SizedBox(height: 16),

          DropdownMenu<String>(
            width: double.infinity,
            label: const Text('Status'),
            leadingIcon: const Icon(Icons.task_alt_outlined),
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'New',
                label: 'New',
              ),
              DropdownMenuEntry(
                value: 'In progress',
                label: 'In progress',
              ),
              DropdownMenuEntry(
                value: 'Completed',
                label: 'Completed',
              ),
            ],
          ),

          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save assignment'),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}