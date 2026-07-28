import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings.defaultSettings();

  AppSettings get settings => _settings;
  AppTheme get theme => _settings.theme;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load from local storage
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
  }

  Future<void> updateTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
  }

  Color get neonColor {
    switch (theme) {
      case AppTheme.redNeon:
        return const Color(0xffff0040);
      case AppTheme.blueNeon:
        return const Color(0xff00a3ff);
      case AppTheme.greenNeon:
        return const Color(0xff39ff88);
    }
  }

  Color get neonAccentColor {
    switch (theme) {
      case AppTheme.redNeon:
        return const Color(0xffcc0033);
      case AppTheme.blueNeon:
        return const Color(0xff0080cc);
      case AppTheme.greenNeon:
        return const Color(0xff1f8a52);
    }
  }
}
