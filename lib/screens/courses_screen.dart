import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  static const weekdays = [
    'All',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CourseModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: _buildBody(context, model),
    );
  }

  Widget _buildBody(BuildContext context, CourseModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.error != null) {
      return ErrorView(
        message: model.error!,
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
          'My courses',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${model.courses.length} education courses',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        const TextField(
          decoration: InputDecoration(
            hintText: 'Search course',
            prefixIcon: Icon(Icons.search),
          ),
        ),

        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: weekdays.map((weekday) {
              final selected = weekday == 'All';

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(weekday),
                  selected: selected,
                  onSelected: (_) {},
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        ...model.courses.map(
          (course) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CourseCard(
              course: course,
              showWeekday: true,
              onTap: () {
                context.push('/courses/${course.id}');
              },
            ),
          ),
        ),
      ],
    );
  }
}
