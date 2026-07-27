import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'is_dark_mode';
  static const String _themeKey = 'selected_theme';
  static const String _languageKey = 'language';
  static const String _requirePasswordKey = 'require_password';
  
  bool _isDarkMode = true;
  String _selectedTheme = 'blue_neon';
  String _language = 'fa';
  bool _requirePasswordOnLogin = false;
  
  bool get isDarkMode => _isDarkMode;
  String get selectedTheme => _selectedTheme;
  String get language => _language;
  bool get requirePasswordOnLogin => _requirePasswordOnLogin;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
    _selectedTheme = prefs.getString(_themeKey) ?? 'blue_neon';
    _language = prefs.getString(_languageKey) ?? 'fa';
    _requirePasswordOnLogin = prefs.getBool(_requirePasswordKey) ?? false;
    notifyListeners();
  }
  
  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
  
  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTheme = theme;
    await prefs.setString(_themeKey, theme);
    notifyListeners();
  }
  
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    _language = language;
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }
  
  Future<void> setRequirePassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _requirePasswordOnLogin = value;
    await prefs.setBool(_requirePasswordKey, value);
    notifyListeners();
  }
}