import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inquiry_system_frontend/main.dart';

void main() {
  testWidgets('shows login screen for signed-out users',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const InquiryApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, student'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
  });
}
