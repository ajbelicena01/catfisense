import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/themed_action_button.dart';
import '../widgets/themed_labeled_text_field.dart';
import 'otp.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpPage(
        subtitle: "We'll text a code to your registered number to confirm the change.",
        onConfirmed: _confirmChange,
      ),
    ));
  }

  Future<void> _confirmChange() async {
    setState(() => _isLoading = true);
    final result = await _authService.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Password updated'),
          content: const Text('Use your new password next time you log in.'),
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
        title: const Text('Change Password'),
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
                  "Enter your current password and choose a new one. We'll send a "
                  'code to confirm before the change takes effect.',
                  style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                ThemedLabeledTextField(
                  label: 'Current Password',
                  icon: Icons.lock_outline,
                  controller: _currentPasswordController,
                  hintText: 'enter your current password',
                  obscureText: true,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter your current password' : null,
                ),
                const SizedBox(height: 20),
                ThemedLabeledTextField(
                  label: 'New Password',
                  icon: Icons.lock_outline,
                  controller: _newPasswordController,
                  hintText: 'enter your new password',
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),
                ThemedLabeledTextField(
                  label: 'Confirm New Password',
                  icon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  hintText: 'confirm your new password',
                  obscureText: true,
                  validator: (value) =>
                      value != _newPasswordController.text ? 'Passwords do not match' : null,
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
