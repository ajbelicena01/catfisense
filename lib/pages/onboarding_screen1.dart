import 'package:flutter/material.dart';

import '../utils/slide_page_route.dart';
import '../widgets/onboarding_scaffold.dart';
import 'dashboard_page.dart';
import 'onboarding_screen2.dart';

const _assets = [
  // Background wave first, decorative bubbles/spiral/current-lines next,
  // the three catfish last so they're never covered by background shapes.
  'assets/onboarding/screen1/16.png',
  'assets/onboarding/screen1/2.png',
  'assets/onboarding/screen1/3.png',
  'assets/onboarding/screen1/4.png',
  'assets/onboarding/screen1/5.png',
  'assets/onboarding/screen1/6.png',
  'assets/onboarding/screen1/7.png',
  'assets/onboarding/screen1/8.png',
  'assets/onboarding/screen1/9.png',
  'assets/onboarding/screen1/10.png',
  'assets/onboarding/screen1/17.png',
  'assets/onboarding/screen1/14.png',
  'assets/onboarding/screen1/15.png',
  'assets/onboarding/screen1/11.png',
  'assets/onboarding/screen1/12.png',
  'assets/onboarding/screen1/13.png',
];

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      illustrationAssets: _assets,
      headline: "Your pond's health\nis in your hands.",
      description: 'Monitor your catfish pond anytime, anywhere.',
      pageIndex: 0,
      totalPages: 4,
      onNext: () => Navigator.of(context).push(slidePageRoute(const OnboardingScreen2())),
      onSkip: () => Navigator.of(context)
          .pushAndRemoveUntil(slidePageRoute(const DashboardPage()), (route) => false),
    );
  }
}
