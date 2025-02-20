import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _isDarkMode = pref.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('isDarkMode', _isDarkMode);
  }
}

