import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/auth_gate.dart';
import 'services/alert_preferences.dart';
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
  runApp(CatfiSenseApp(themeController: themeController, alertPreferences: alertPreferences));
}

class CatfiSenseApp extends StatelessWidget {
  const CatfiSenseApp({super.key, required this.themeController, required this.alertPreferences});

  final ThemeController themeController;
  final AlertPreferences alertPreferences;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: alertPreferences),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'CatfiSense',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: theme.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
