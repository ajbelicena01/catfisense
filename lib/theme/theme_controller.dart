import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _darkModeKey = 'isDarkMode';

class ThemeController extends ChangeNotifier {
  ThemeController(this._isDarkMode);

  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeController(prefs.getBool(_darkModeKey) ?? false);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
