import 'package:flutter_test/flutter_test.dart';
import 'package:edu_plan/main.dart';

void main() {
  testWidgets('EduPlan login screen is displayed', (tester) async {
    await tester.pumpWidget(const EduPlanApp());

    expect(find.text('EduPlan'), findsOneWidget);
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });
}