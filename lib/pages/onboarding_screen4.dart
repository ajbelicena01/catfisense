import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

import '../widgets/onboarding_scaffold.dart';

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
      headline: context.l10n.onboarding4Headline,
      description: context.l10n.onboarding4Body,
      pageIndex: 3,
      totalPages: 4,
      onNext: () => Navigator.of(context)
          .popUntil((route) => route.isFirst),
      onSkip: () => Navigator.of(context)
          .popUntil((route) => route.isFirst),
    );
  }
}
