import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'appLanguage';

/// The app's language choice. Null follows the phone's language (Filipino
/// phones get Filipino, everything else English).
class LanguageController extends ChangeNotifier {
  LanguageController(this._languageCode);

  static const supportedCodes = ['en', 'fil'];

  String? _languageCode;
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);

  static Future<LanguageController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    return LanguageController(supportedCodes.contains(saved) ? saved : null);
  }

  Future<void> setLanguage(String? code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, code);
    }
  }
}
