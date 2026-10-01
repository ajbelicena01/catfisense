import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../services/pond_service.dart';
import '../services/sensor_repository.dart';
import 'admin/admin_home_page.dart';
import 'dashboard_page.dart';
import 'loading_screen.dart';
import 'pond_code_page.dart';
import 'splash_screen.dart';

enum _GateScreen { loading, welcome, pondCode, dashboard, admin }

/// The app's root screen, chosen from the saved session:
///   - not logged in           -> welcome (LOGIN / SIGN UP)
///   - logged in, no pond yet  -> pond code entry
///   - logged in, pond linked  -> dashboard
///   - an admin account        -> admin area (no pond needed)
///
/// It reacts to sign-in, sign-out and pond linking on its own, so the login,
/// signup and onboarding flows just pop back to the first route when done
/// instead of pushing the dashboard themselves.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _pondService = PondService();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<PondMembership?>? _pondSub;
  StreamSubscription<bool>? _adminSub;
  _GateScreen _screen = _GateScreen.loading;

  // Keeps the loading screen's animation visible for a deliberate minimum
  // instead of flashing by instantly.
  bool _minimumSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _minimumSplashElapsed = true);
    });
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  Future<void> _onUserChanged(User? user) async {
    _pondSub?.cancel();
    _pondSub = null;
    _adminSub?.cancel();
    _adminSub = null;
    if (user == null) {
      _show(_GateScreen.welcome);
      return;
    }
    _show(_GateScreen.loading);

    // Admin usernames are recognisable straight away (even offline); the
    // admins/ list is what actually grants access, so it has the last word.
    final looksLikeAdmin = AuthService.isAdminUsername(user.email?.split('@').first ?? '');
    if (looksLikeAdmin) _show(_GateScreen.admin);
    _adminSub = const AdminService().isAdmin(user.uid).listen((isAdmin) {
      if (isAdmin) {
        _pondSub?.cancel();
        _pondSub = null;
        _show(_GateScreen.admin);
      } else if (_pondSub == null) {
        _watchPond(user);
      }
    }, onError: (Object _) {
      if (_pondSub == null && !looksLikeAdmin) _watchPond(user);
    });
  }

  Future<void> _watchPond(User user) async {
    // Open the dashboard straight away for a pond this phone already knows
    // about, even offline; the live value below corrects it if it changed.
    final cached = await _pondService.cachedPondId(user.uid);
    if (!mounted || FirebaseAuth.instance.currentUser?.uid != user.uid) return;
    if (cached != null) _showDashboard(cached);
    // Signing out can cancel the pond listeners with a permission error just
    // before authStateChanges reports it; the welcome screen follows then.
    void showPondCode() {
      if (FirebaseAuth.instance.currentUser != null) _show(_GateScreen.pondCode);
    }

    if (_pondSub != null) return;
    _pondSub = _pondService.membership(user.uid).listen(
      (membership) => membership == null ? showPondCode() : _showDashboard(membership.pondId),
      onError: (Object _) => showPondCode(),
    );
  }

  /// The farmer screens read [SensorRepository.deviceId], so it is set
  /// first; a different pond gets a fresh dashboard.
  void _showDashboard(String pondId) {
    SensorRepository.deviceId = pondId;
    _show(_GateScreen.dashboard);
  }

  void _show(_GateScreen screen) {
    if (mounted) setState(() => _screen = screen);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _pondSub?.cancel();
    _adminSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = _minimumSplashElapsed ? _screen : _GateScreen.loading;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: switch (screen) {
        _GateScreen.loading => const LoadingScreen(key: ValueKey('loading')),
        _GateScreen.welcome => const SplashScreen(key: ValueKey('welcome')),
        _GateScreen.pondCode => const PondCodePage(key: ValueKey('pondCode')),
        _GateScreen.dashboard => DashboardPage(key: ValueKey('dashboard-${SensorRepository.deviceId}')),
        _GateScreen.admin => const AdminHomePage(key: ValueKey('admin')),
      },
    );
  }
}
