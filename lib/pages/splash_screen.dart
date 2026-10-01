import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

import '../widgets/app_buttons.dart';
import 'login_page.dart';
import 'signup_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 402 / 346,
              child: Image.asset('assets/images/wave_top.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 402 / 201,
              child: Image.asset('assets/images/wave_bottom.png', fit: BoxFit.cover),
            ),
          ),
          const Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Text(
              '©2026',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Image.asset('assets/images/logo_header.png', width: 280),
                  const Spacer(flex: 2),
                  FilledActionButton(
                    label: context.l10n.welcomeLogin,
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const LoginPage())),
                  ),
                  const SizedBox(height: 16),
                  OutlinedActionButton(
                    label: context.l10n.welcomeSignup,
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const SignupPage())),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
