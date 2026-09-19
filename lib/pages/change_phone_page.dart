import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/themed_action_button.dart';
import '../widgets/themed_labeled_text_field.dart';
import 'otp.dart';

class ChangePhoneNumberPage extends StatefulWidget {
  const ChangePhoneNumberPage({super.key});

  @override
  State<ChangePhoneNumberPage> createState() => _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends State<ChangePhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpPage(
        subtitle: "We'll text a code to your new number to confirm the change.",
        onConfirmed: _confirmChange,
      ),
    ));
  }

  Future<void> _confirmChange() async {
    setState(() => _isLoading = true);
    final result = await _authService.updatePhoneNumber(
      currentPassword: _passwordController.text,
      newPhone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Phone number updated'),
          content: const Text('You can now log in with your new number.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK')),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // OtpPage
      Navigator.of(context).pop(); // back to Settings
    } else {
      Navigator.of(context).pop(); // OtpPage, back to the form to retry
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        title: const Text('Change Phone Number'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your new number and current password. '
                  "We'll send a code to confirm before the change takes effect.",
                  style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                ThemedLabeledTextField(
                  label: 'New Phone Number',
                  icon: Icons.phone_android,
                  controller: _phoneController,
                  hintText: '(09) 00 000 0000',
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),
                const SizedBox(height: 20),
                ThemedLabeledTextField(
                  label: 'Current Password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  hintText: 'enter your current password',
                  obscureText: true,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter your current password' : null,
                ),
                const SizedBox(height: 32),
                ThemedFilledButton(label: 'SEND OTP', onPressed: _sendOtp, isLoading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
