import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_config.dart';
import 'data/auth_api.dart';
import 'data/mock_edu_plan_repository.dart';
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

  // Courses and assignments are intentionally still using
  // the L4 mock repository at this stage.
  // They will be replaced by HTTP repositories later in L5.
  final repository = MockEduPlanRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>.value(value: authApi),

        Provider<MockEduPlanRepository>.value(value: repository),

        ChangeNotifierProvider(create: (_) => CourseModel(repository)..load()),

        ChangeNotifierProvider(
          create: (_) => AssignmentModel(repository)..load(),
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
