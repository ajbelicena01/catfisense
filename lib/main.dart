import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'pages/auth_gate.dart';
import 'services/alert_preferences.dart';
import 'services/language_controller.dart';
import 'services/maintenance_controller.dart';
import 'services/notification_service.dart';
import 'services/threshold_controller.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android auto-initializes the default Firebase app natively (from
  // google-services.json) before this ever runs. Firebase.apps on the Dart
  // side doesn't know about that native app until it tries to register one
  // itself and collides, so check by isEmpty doesn't work — catch the
  // specific duplicate-app exception instead and treat it as already-done.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  final themeController = await ThemeController.load();
  final alertPreferences = await AlertPreferences.load();
  final languageController = await LanguageController.load();
  final thresholdController = await ThresholdController.load();
  final maintenanceController = MaintenanceController(alertPreferences);
  runApp(
    CatfiSenseApp(
      themeController: themeController,
      alertPreferences: alertPreferences,
      languageController: languageController,
      thresholdController: thresholdController,
      maintenanceController: maintenanceController,
    ),
  );
}

class CatfiSenseApp extends StatelessWidget {
  const CatfiSenseApp({
    super.key,
    required this.themeController,
    required this.alertPreferences,
    required this.languageController,
    required this.thresholdController,
    required this.maintenanceController,
  });

  final ThemeController themeController;
  final AlertPreferences alertPreferences;
  final LanguageController languageController;
  final ThresholdController thresholdController;
  final MaintenanceController maintenanceController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: alertPreferences),
        ChangeNotifierProvider.value(value: languageController),
        // Screens that judge readings watch this to redraw with new ranges.
        ChangeNotifierProvider.value(value: thresholdController),
        ChangeNotifierProvider.value(value: maintenanceController),
      ],
      child: Consumer2<ThemeController, LanguageController>(
        builder: (context, theme, language, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: theme.themeMode,
            locale: language.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              // Keep background notifications in the same language as the app.
              NotificationService.instance.l10n = AppLocalizations.of(context);
              final mediaQuery = MediaQuery.of(context);
              final systemScale = mediaQuery.textScaler.scale(1.0);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(systemScale * theme.textScale),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
