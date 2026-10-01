import 'package:catfisense/l10n/app_localizations.dart';
import 'package:catfisense/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const SplashScreen(),
);

void main() {
  testWidgets('Splash screen shows login and sign up buttons', (WidgetTester tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('Splash screen is translated to Filipino', (WidgetTester tester) async {
    await tester.pumpWidget(_app(const Locale('fil')));
    await tester.pumpAndSettle();

    expect(find.text('MAG-LOGIN'), findsOneWidget);
    expect(find.text('MAG-SIGN UP'), findsOneWidget);
  });
}
