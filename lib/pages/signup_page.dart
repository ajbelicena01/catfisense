import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/slide_page_route.dart';
import '../utils/validators.dart';
import '../widgets/app_buttons.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/section_heading.dart';
import 'login_page.dart';
import 'otp.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _authService.signUp(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      Navigator.of(context).push(
        slidePageRoute(
          OtpPage(
            // Back to AuthGate, which now shows the pond code screen; the
            // onboarding tour follows once a pond is linked.
            onConfirmed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!.message(context.l10n))));
    }
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
                    SectionHeading(text: context.l10n.signupTitle),
                    const SizedBox(height: 24),
                    LabeledTextField(
                      label: context.l10n.fieldPhone,
                      icon: Icons.phone_android,
                      controller: _phoneController,
                      hintText: '(09) 00 000 0000',
                      keyboardType: TextInputType.phone,
                      validator: (value) => validatePhone(context.l10n, value),
                    ),
                    const SizedBox(height: 20),
                    LabeledTextField(
                      label: context.l10n.fieldPassword,
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      hintText: context.l10n.fieldPasswordHint,
                      obscureText: true,
                      validator: (value) => validatePassword(context.l10n, value),
                    ),
                    const SizedBox(height: 20),
                    LabeledTextField(
                      label: context.l10n.signupConfirmPassword,
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      hintText: context.l10n.signupConfirmHint,
                      obscureText: true,
                      validator: (value) => value != _passwordController.text
                          ? context.l10n.signupPasswordsMismatch
                          : null,
                    ),
                    const SizedBox(height: 32),
                    FilledActionButton(
                      label: context.l10n.signupButton,
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [
                              TextSpan(text: context.l10n.signupHaveAccount),
                              TextSpan(
                                text: context.l10n.signupLoginLink,
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
