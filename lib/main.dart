import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/theme_data.dart';
import 'screens/galaxy_background.dart';
import 'screens/dashboard_tab.dart';
import 'screens/inbounds_tab.dart';
import 'screens/users_tab.dart';
import 'screens/scanner_tab.dart';
import 'screens/settings_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/profile_sidebar.dart';

void main() {
  runApp(const SpiderApp());
}

class SpiderApp extends StatelessWidget {
  const SpiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Spider Panel',
            debugShowCheckedModeBanner: false,
            theme: SpiderTheme.buildTheme(settings.theme),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return Scaffold(
        body: GalaxyBackground(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    // Check if this is first launch
    final hasToken = auth.backendToken.isNotEmpty;
    if (!hasToken) {
      return const WelcomeScreen();
    }

    return const LoginScreen();
  }
}