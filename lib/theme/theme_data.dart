import 'package:flutter/material.dart';

enum AppTheme { redNeon, blueNeon, greenNeon }

class ThemeColors {
  final Color neon;
  final Color neonAccent;
  final Color cardBackground;
  final Color sidebarBackground;

  const ThemeColors({
    required this.neon,
    required this.neonAccent,
    required this.cardBackground,
    required this.sidebarBackground,
  });
}

class SpiderTheme {
  static const _redNeon = ThemeColors(
    neon: Color(0xFFFF2A55),
    neonAccent: Color(0xFFFF5277),
    cardBackground: Color(0x0DFFFFFF),
    sidebarBackground: Color(0xE6020617),
  );

  static const _blueNeon = ThemeColors(
    neon: Color(0xFF38BDF8),
    neonAccent: Color(0xFF6366F1),
    cardBackground: Color(0x0DFFFFFF),
    sidebarBackground: Color(0xE6020617),
  );

  static const _greenNeon = ThemeColors(
    neon: Color(0xFF34D399),
    neonAccent: Color(0xFF10B981),
    cardBackground: Color(0x0DFFFFFF),
    sidebarBackground: Color(0xE6020617),
  );

  static const backgroundColor = Color(0xFF020617);

  static ThemeColors colorsFor(BuildContext context) {
    // Read theme from InheritedWidget or default to blueNeon
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.light) {
      return const ThemeColors(
        neon: Color(0xFF38BDF8),
        neonAccent: Color(0xFF6366F1),
        cardBackground: Color(0xF0FFFFFF),
        sidebarBackground: Color(0xFFF8FAFC),
      );
    }
    // Detect primary color to pick neon set
    final primary = theme.colorScheme.primary;
    if (primary.value == _redNeon.neon.value) return _redNeon;
    if (primary.value == _greenNeon.neon.value) return _greenNeon;
    return _blueNeon;
  }

  static ThemeData buildTheme(AppTheme appTheme) {
    final colorScheme = switch (appTheme) {
      AppTheme.redNeon => const ColorScheme.dark(
          primary: Color(0xFFFF2A55),
          secondary: Color(0xFFFF5277),
          background: Color(0xFF0D0206),
          surface: Color(0xFF1E0810),
        ),
      AppTheme.blueNeon => const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF6366F1),
          background: Color(0xFF020617),
          surface: Color(0xFF0F172A),
        ),
      AppTheme.greenNeon => const ColorScheme.dark(
          primary: Color(0xFF34D399),
          secondary: Color(0xFF10B981),
          background: Color(0xFF020F07),
          surface: Color(0xFF082112),
        ),
    };

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}