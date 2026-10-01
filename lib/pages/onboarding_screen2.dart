import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

import '../utils/slide_page_route.dart';
import '../widgets/onboarding_scaffold.dart';
import 'onboarding_screen3.dart';

const _assets = [
  'assets/onboarding/screen2/2.png',
  'assets/onboarding/screen2/3.png',
  'assets/onboarding/screen2/4.png',
  'assets/onboarding/screen2/5.png',
  'assets/onboarding/screen2/6.png',
];

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      illustrationAssets: _assets,
      headline: context.l10n.onboarding2Headline,
      description: context.l10n.onboarding2Body,
      pageIndex: 1,
      totalPages: 4,
      onNext: () => Navigator.of(context).push(slidePageRoute(const OnboardingScreen3())),
      onSkip: () => Navigator.of(context)
          .popUntil((route) => route.isFirst),
    );
  }
}
