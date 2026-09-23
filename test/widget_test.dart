import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_plan/main.dart';

void main() {
  testWidgets('EduPlan login screen is displayed', (tester) async {
    await tester.pumpWidget(const EduPlanApp());

    expect(find.text('EduPlan'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(FilledButton), findsOneWidget);
  });
}