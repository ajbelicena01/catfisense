import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _darkModeKey = 'isDarkMode';
const _textScaleKey = 'appTextScale';
const minAppTextScale = 0.85;
const maxAppTextScale = 1.30;

class ThemeController extends ChangeNotifier {
  ThemeController(this._isDarkMode, {double textScale = 1.0})
    : _textScale = textScale.clamp(minAppTextScale, maxAppTextScale).toDouble();

  bool _isDarkMode;
  double _textScale;
  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeController(
      prefs.getBool(_darkModeKey) ?? false,
      textScale: prefs.getDouble(_textScaleKey) ?? 1.0,
    );
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextScale(double value) async {
    final normalized = value.clamp(minAppTextScale, maxAppTextScale).toDouble();
    if (_textScale == normalized) return;
    _textScale = normalized;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, normalized);
  }
}
