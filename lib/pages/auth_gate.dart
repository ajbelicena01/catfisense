import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'loading_screen.dart';

/// Single-device, single-owner deployment: no login is required to see the
/// pond dashboard, since sensor data now lives at a fixed device path
/// (readings/pond1) rather than being scoped per Firebase Auth account.
/// This briefly shows the loading screen, then always opens the dashboard.
///
/// The login/signup/OTP screens still exist in the codebase (reachable from
/// the drawer/settings if you want optional account features later, e.g.
/// personalized alert delivery), they're just no longer required to view
/// live readings.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Keeps the loading screen's animation visible for a deliberate minimum
  // instead of flashing by instantly.
  bool _minimumSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _minimumSplashElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _minimumSplashElapsed
          ? const DashboardPage(key: ValueKey('dashboard'))
          : const LoadingScreen(key: ValueKey('loading')),
    );
  }
}
