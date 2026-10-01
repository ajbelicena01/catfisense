import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's strings in the current language: `context.l10n.loginTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
