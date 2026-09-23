import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/course_card.dart';
import '../widgets/edu_plan_drawer.dart';
import 'schedule_screen.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: EduPlanDrawer(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          Navigator.pop(context);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleScreen(),
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: ListView(
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
            '${mockCourses.length} education courses',
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

          ...mockCourses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CourseCard(
                course: course,
                showWeekday: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}