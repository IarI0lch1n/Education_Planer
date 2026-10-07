import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/assignment_form_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/course_details_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'widgets/app_shell.dart';

final _scheduleNavigatorKey = GlobalKey<NavigatorState>();
final _coursesNavigatorKey = GlobalKey<NavigatorState>();
final _assignmentsNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          navigationShell: navigationShell,
        );
      },
      branches: [
        // Schedule
        StatefulShellBranch(
          navigatorKey: _scheduleNavigatorKey,
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const ScheduleScreen(),
              routes: [
                GoRoute(
                  path: 'course/:id',
                  builder: (context, state) {
                    final id = int.parse(
                      state.pathParameters['id']!,
                    );

                    return CourseDetailsScreen(
                      id: id,
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Courses
        StatefulShellBranch(
          navigatorKey: _coursesNavigatorKey,
          routes: [
            GoRoute(
              path: '/courses',
              builder: (context, state) => const CoursesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(
                      state.pathParameters['id']!,
                    );

                    return CourseDetailsScreen(
                      id: id,
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Assignments
        StatefulShellBranch(
          navigatorKey: _assignmentsNavigatorKey,
          routes: [
            GoRoute(
              path: '/assignments',
              builder: (context, state) =>
                  const AssignmentsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) =>
                      const AssignmentFormScreen(),
                ),
              ],
            ),
          ],
        ),

        // Profile
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);