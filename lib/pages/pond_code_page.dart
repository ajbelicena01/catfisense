import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';
import '../services/pond_service.dart';
import '../theme/app_colors.dart';
import '../utils/slide_page_route.dart';
import '../widgets/app_buttons.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/section_heading.dart';
import 'onboarding_screen1.dart';

/// Shown by [AuthGate] to a signed-in account that isn't linked to a pond
/// yet. Once the code is accepted, the gate switches to the dashboard on its
/// own; this page only pushes the onboarding tour on top of it.
class PondCodePage extends StatefulWidget {
  const PondCodePage({super.key});

  @override
  State<PondCodePage> createState() => _PondCodePageState();
}

class _PondCodePageState extends State<PondCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _pondService = PondService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Captured before the await: the gate replaces this page as soon as the
    // link lands, but the root navigator stays valid.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _isLoading = true);
    final result = await _pondService.joinWithCode(_codeController.text);
    if (mounted) setState(() => _isLoading = false);
    if (!result.success) {
      messenger.showSnackBar(SnackBar(content: Text(result.error!.message(l10n))));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.role == PondRole.owner ? l10n.pondCodeJoinedOwner : l10n.pondCodeJoinedCaretaker),
      ),
    );
    navigator.push(slidePageRoute(const OnboardingScreen1()));
  }

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
              child: Image.asset(
                'assets/images/wave_top.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo_header.png', width: 220),
                    const SizedBox(height: 24),
                    SectionHeading(text: context.l10n.pondCodeTitle),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.pondCodeBody,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    LabeledTextField(
                      label: context.l10n.pondCodeField,
                      icon: Icons.vpn_key_outlined,
                      controller: _codeController,
                      hintText: 'XXXX-XXXX',
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) => PondService.validateCode(context.l10n, value),
                    ),
                    const SizedBox(height: 32),
                    FilledActionButton(
                      label: context.l10n.pondCodeButton,
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => AuthService().signOut(),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [
                              TextSpan(text: context.l10n.pondCodeWrongAccount),
                              TextSpan(
                                text: context.l10n.pondCodeLogout,
                                style: TextStyle(
                                  color: kBrandOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
