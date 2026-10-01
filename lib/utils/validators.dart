import '../l10n/app_localizations.dart';

String? validatePhone(AppLocalizations l10n, String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11 || !digits.startsWith('09')) {
    return l10n.validatePhone;
  }
  return null;
}

/// Login accepts a phone number or an admin username.
String? validatePhoneOrAdmin(AppLocalizations l10n, String? value) {
  final input = (value ?? '').trim().toLowerCase();
  if (input.startsWith('admin_')) {
    return RegExp(r'^admin_[a-z0-9_]{2,30}$').hasMatch(input) ? null : l10n.validateAdminUsername;
  }
  return validatePhone(l10n, value);
}

String? validatePassword(AppLocalizations l10n, String? value) {
  final password = value ?? '';
  if (password.length < 8) {
    return l10n.validatePasswordLength;
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return l10n.validatePasswordCapital;
  }
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
    return l10n.validatePasswordSymbol;
  }
  return null;
}
