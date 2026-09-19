import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';

/// Shown by [AuthGate] while it's still determining whether a session is
/// already saved. Brief on most opens, but the animation gives that moment
/// some life instead of a bare spinner.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: DotLottieView(
            sourceType: 'asset',
            source: 'animations/loading.lottie',
            autoplay: true,
            loop: true,
          ),
        ),
      ),
    );
  }
}
