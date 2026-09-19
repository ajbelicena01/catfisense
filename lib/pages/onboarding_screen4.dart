import 'package:flutter/material.dart';

import '../utils/slide_page_route.dart';
import '../widgets/onboarding_scaffold.dart';
import 'dashboard_page.dart';

const _assets = [
  'assets/onboarding/screen4/3.png',
  'assets/onboarding/screen4/4.png',
  'assets/onboarding/screen4/5.png',
  'assets/onboarding/screen4/6.png',
  'assets/onboarding/screen4/7.png',
  'assets/onboarding/screen4/notf.png',
];

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      illustrationAssets: _assets,
      headline: 'Get alerts when\naction is needed.',
      description: 'Receive mobile and SMS alerts with expert-guided recommendations.',
      pageIndex: 3,
      totalPages: 4,
      onNext: () => Navigator.of(context)
          .pushAndRemoveUntil(slidePageRoute(const DashboardPage()), (route) => false),
      onSkip: () => Navigator.of(context)
          .pushAndRemoveUntil(slidePageRoute(const DashboardPage()), (route) => false),
    );
  }
}
