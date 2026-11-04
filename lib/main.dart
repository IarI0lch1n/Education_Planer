import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_config.dart';
import 'data/auth_api.dart';
import 'data/http_assignment_repository.dart';
import 'data/http_course_repository.dart';
import 'data/token_store.dart';
import 'models/assignment_model.dart';
import 'models/course_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokens = TokenStore();

  final loggedIn = await tokens.read() != null;

  configureRouter(loggedIn: loggedIn);

  final authApi = AuthApi(apiBaseUrl, tokens);

  final courseRepository = HttpCourseRepository(
    apiBaseUrl,
    tokens,
    onUnauthorized: () {
      router.go('/login');
    },
  );

  final assignmentRepository = HttpAssignmentRepository(
    apiBaseUrl,
    tokens,
    onUnauthorized: () {
      router.go('/login');
    },
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>.value(value: authApi),

        ChangeNotifierProvider(
          create: (_) {
            final model = CourseModel(courseRepository);

            if (loggedIn) {
              model.load();
            }

            return model;
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final model = AssignmentModel(assignmentRepository);

            if (loggedIn) {
              model.load();
            }

            return model;
          },
        ),
      ],
      child: const EduPlanApp(),
    ),
  );
}

class EduPlanApp extends StatelessWidget {
  const EduPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduPlan',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
