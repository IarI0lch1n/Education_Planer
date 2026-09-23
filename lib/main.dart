import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const EduPlanApp());
}

class EduPlanApp extends StatelessWidget {
  const EduPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduPlan',
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('EduPlan'),
        ),
      ),
    );
  }
}