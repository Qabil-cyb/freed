import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';

class SpiderTheme {
  static const Map<AppTheme, ThemeColors> themes = {
    AppTheme.redNeon: ThemeColors(
      neon: Color(0xffff0040),
      neonAccent: Color(0xffcc0033),
      neonGlow: Color(0x88ff0040),
    ),
    AppTheme.blueNeon: ThemeColors(
      neon: Color(0xff00a3ff),
      neonAccent: Color(0xff0080cc),
      neonGlow: Color(0x8800a3ff),
    ),
    AppTheme.greenNeon: ThemeColors(
      neon: Color(0xff39ff88),
      neonAccent: Color(0xff1f8a52),
      neonGlow: Color(0x8839ff88),
    ),
  };

  static ThemeColors colorsFor(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    return themes[provider.theme] ?? themes[AppTheme.greenNeon]!;
  }

  static ThemeColors colorsForSettings(AppTheme theme) {
    return themes[theme] ?? themes[AppTheme.greenNeon]!;
  }

  static ThemeData buildTheme(AppTheme appTheme) {
    final colors = themes[appTheme]!;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff0a0a1a),
      colorScheme: ColorScheme.dark(
        primary: colors.neon,
        secondary: colors.neonAccent,
        surface: const Color(0xff121225),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
        bodySmall: TextStyle(color: Colors.white54),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.neon.withAlpha(80)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.neon.withAlpha(80)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.neon, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
        labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.neon,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withAlpha(15),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(25)),
        ),
      ),
      iconTheme: IconThemeData(color: colors.neon),
      drawerTheme: DrawerThemeData(
        backgroundColor: const Color(0xff0a0a1a).withAlpha(240),
      ),
    );
  }
}

class ThemeColors {
  final Color neon;
  final Color neonAccent;
  final Color neonGlow;

  const ThemeColors({
    required this.neon,
    required this.neonAccent,
    required this.neonGlow,
  });
}
