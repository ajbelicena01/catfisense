import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_buttons.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/section_heading.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;

  // Admins log in with a username (admin_…) instead of a phone number.
  bool _adminMode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _authService.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!result.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!.message(context.l10n))));
      return;
    }
    // AuthGate shows the dashboard or the pond code screen for this account.
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                    SectionHeading(text: context.l10n.loginTitle),
                    const SizedBox(height: 24),
                    // Keyed so switching modes swaps the keyboard type too.
                    LabeledTextField(
                      key: ValueKey(_adminMode),
                      label: _adminMode ? context.l10n.fieldAdminUsername : context.l10n.fieldPhone,
                      icon: _adminMode ? Icons.admin_panel_settings_outlined : Icons.phone_android,
                      controller: _phoneController,
                      hintText: _adminMode ? 'admin_yourname' : '(09) 00 000 0000',
                      keyboardType: _adminMode ? TextInputType.visiblePassword : TextInputType.phone,
                      validator: (value) => _adminMode
                          ? validatePhoneOrAdmin(context.l10n, value)
                          : validatePhone(context.l10n, value),
                    ),
                    const SizedBox(height: 20),
                    LabeledTextField(
                      label: context.l10n.fieldPassword,
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      hintText: context.l10n.fieldPasswordHint,
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? context.l10n.loginPasswordRequired
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: kBrandOrange,
                                onChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.loginRememberMe,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            context.l10n.loginForgotPassword,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kBrandOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    FilledActionButton(
                      label: context.l10n.loginButton,
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [
                              TextSpan(text: context.l10n.loginNoAccount),
                              TextSpan(
                                text: context.l10n.loginSignupLink,
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
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() {
                          _adminMode = !_adminMode;
                          _phoneController.clear();
                        }),
                        child: Text(
                          _adminMode ? context.l10n.loginAsFarmer : context.l10n.loginAsAdmin,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
