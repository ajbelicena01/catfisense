import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catfisense/pages/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows login and sign up buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });
}
