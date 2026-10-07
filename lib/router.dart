import 'package:go_router/go_router.dart';

import 'screens/assignment_form_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/course_details_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/schedule',
      builder: (context, state) => const ScheduleScreen(),
    ),

    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);

            return CourseDetailsScreen(
              id: id,
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/assignments',
      builder: (context, state) => const AssignmentsScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const AssignmentFormScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);