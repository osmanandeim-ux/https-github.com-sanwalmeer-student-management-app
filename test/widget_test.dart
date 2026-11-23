
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management_app/main.dart';

void main() {
  testWidgets('Student Management app loads login screen', (tester) async {
    // Mock local storage for widget testing.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StudentManagementApp());

    // Allow AuthGate to complete its session check.
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
