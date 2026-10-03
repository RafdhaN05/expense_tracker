import 'package:flutter/material.dart';

/// ThemeProvider manages switching between Light, Dark, and System mode.
class ThemeProvider with ChangeNotifier {
  // Starts with 'system' so it matches your phone's Dark Mode automatically!
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Checks if the app is currently following the phone's system setting
  bool get isSystemMode => _themeMode == ThemeMode.system;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Tells the whole app to update!
  }

  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}