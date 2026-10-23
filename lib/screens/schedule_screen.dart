import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/course.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const weekdays = [
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
      appBar: AppBar(title: const Text('Schedule')),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Education week',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Student_Group · Current week',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),

        ...weekdays.map(
          (weekday) => _DaySection(
            weekday: weekday,
            courses: model.courses
                .where((course) => course.weekday == weekday)
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  final String weekday;
  final List<Course> courses;

  const _DaySection({required this.weekday, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(weekday, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),

          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CourseCard(
                course: course,
                onTap: () {
                  context.push('/schedule/course/${course.id}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
