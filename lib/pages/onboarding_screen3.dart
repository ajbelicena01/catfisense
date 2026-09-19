import 'package:flutter/material.dart';

import '../utils/slide_page_route.dart';
import '../widgets/onboarding_scaffold.dart';
import 'dashboard_page.dart';
import 'onboarding_screen4.dart';

const _assets = [
  // Background goes first so it sits behind the character instead of covering him.
  'assets/onboarding/screen3/3.png',
  'assets/onboarding/screen3/2.png',
  'assets/onboarding/screen3/4.png',
  'assets/onboarding/screen3/5.png',
  'assets/onboarding/screen3/6.png',
];

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      illustrationAssets: _assets,
      headline: "Know your pond's\ncondition instantly.",
      description:
          'CatfiSense analyzes readings and shows whether your pond is Healthy, Warning, or Critical.',
      pageIndex: 2,
      totalPages: 4,
      onNext: () => Navigator.of(context).push(slidePageRoute(const OnboardingScreen4())),
      onSkip: () => Navigator.of(context)
          .pushAndRemoveUntil(slidePageRoute(const DashboardPage()), (route) => false),
    );
  }
}
