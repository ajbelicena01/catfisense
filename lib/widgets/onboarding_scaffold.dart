import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'animated_illustration.dart';

class OnboardingScaffold extends StatefulWidget {
  const OnboardingScaffold({
    super.key,
    required this.illustrationAssets,
    required this.headline,
    required this.description,
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  final List<String> illustrationAssets;
  final String headline;
  final String description;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  bool get isLastPage => pageIndex == totalPages - 1;

  @override
  State<OnboardingScaffold> createState() => _OnboardingScaffoldState();
}

class _OnboardingScaffoldState extends State<OnboardingScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedIllustration(assetPaths: widget.illustrationAssets),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        widget.headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2429),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _DotIndicator(pageIndex: widget.pageIndex, totalPages: widget.totalPages),
                  TextButton(
                    onPressed: widget.onNext,
                    child: Text(
                      widget.isLastPage ? 'Finish' : 'Next',
                      style: const TextStyle(color: kBrandOrange, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatefulWidget {
  const _DotIndicator({required this.pageIndex, required this.totalPages});

  final int pageIndex;
  final int totalPages;

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator> {
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _activated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.totalPages, (index) {
        final isActive = _activated && index == widget.pageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? kBrandOrange : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
