import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

import '../utils/slide_page_route.dart';
import '../widgets/onboarding_scaffold.dart';
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
      headline: context.l10n.onboarding3Headline,
      description: context.l10n.onboarding3Body,
      pageIndex: 2,
      totalPages: 4,
      onNext: () => Navigator.of(context).push(slidePageRoute(const OnboardingScreen4())),
      onSkip: () => Navigator.of(context)
          .popUntil((route) => route.isFirst),
    );
  }
}
