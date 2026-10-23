import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_edu_plan_repository.dart';
import 'models/assignment_model.dart';
import 'models/course_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  final repository = MockEduPlanRepository();

  runApp(
    MultiProvider(
      providers: [
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
