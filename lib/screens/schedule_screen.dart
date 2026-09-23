import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/course_card.dart';
import '../widgets/edu_plan_drawer.dart';

import 'courses_screen.dart';

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
    return Scaffold(
      drawer: EduPlanDrawer(
        selectedIndex: 0,
        onDestinationSelected: (index) {
        Navigator.pop(context);

        if (index == 1) {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const CoursesScreen(),
            ),
            );
        }
        },
      ),
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Eduation week',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student_Group · Current week',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...weekdays.map(
            (weekday) => _DaySection(
              weekday: weekday,
              courses: mockCourses
                  .where((course) => course.weekday == weekday)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String weekday;
  final List<Course> courses;

  const _DaySection({
    required this.weekday,
    required this.courses,
  });

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
          Text(
            weekday,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CourseCard(
                course: course,
              ),
            ),
          ),
        ],
      ),
    );
  }
}