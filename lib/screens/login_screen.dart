import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final ok = await auth.login(_urlCtrl.text.trim().replaceAll(RegExp(r'/+$'), ''), _keyCtrl.text.trim());
    setState(() => _loading = false);
    if (ok && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ApiService(auth)),
        ],
        child: const HomeScreen(),
      )));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3F3D99)]), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.5), blurRadius: 20)]),
                  child: const Center(child: Text('🕷️', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 24), const Text('Spider Panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),
                TextField(controller: _urlCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Panel URL', hintText: 'https://...', prefixIcon: Icon(Icons.link, color: Color(0xFF6C63FF)))),
                const SizedBox(height: 16),
                TextField(controller: _keyCtrl, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'API Key', hintText: 'sk_...', prefixIcon: Icon(Icons.key, color: Color(0xFF6C63FF)))),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
