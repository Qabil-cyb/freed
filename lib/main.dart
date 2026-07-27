import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/screens/auth/login_screen.dart';
import 'package:spider_vpn/screens/home/home_screen.dart';
import 'package:spider_vpn/screens/shared/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SpiderVPNApp(),
    ),
  );
}

class SpiderVPNApp extends StatelessWidget {
  const SpiderVPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return MaterialApp(
          title: 'Spider VPN Panel',
          debugShowCheckedModeBanner: false,
          theme: settingsProvider.isDarkMode 
            ? SpiderTheme.darkTheme 
            : SpiderTheme.lightTheme,
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.isAuthenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}