import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      if (auth.isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MultiProvider(
          providers: [ChangeNotifierProvider.value(value: auth), ChangeNotifierProvider(create: (_) => ApiService(auth))],
          child: const HomeScreen(),
        )));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MultiProvider(
          providers: [ChangeNotifierProvider.value(value: auth), ChangeNotifierProvider(create: (_) => ApiService(auth))],
          child: const LoginScreen(),
        )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3F3D99)]),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.5), blurRadius: 30)],
              ),
              child: const Center(child: Text('🕷️', style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 24),
            const Text('Spider Panel', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Made By Amir', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
          ]),
        ),
      ),
    );
  }
}
