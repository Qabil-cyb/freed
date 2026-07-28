import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Backend Token');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService().setup(token);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      setState(() => _errorMessage = response.message ?? 'Connection failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GalaxyBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo area
                GlassContainer(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.only(bottom: 32),
                  blur: 15,
                  child: Column(
                    children: [
                      Icon(
                        Icons.language,
                        size: 80,
                        color: SpiderTheme.colorsFor(context).neon,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Spider Panel',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: SpiderTheme.colorsFor(context).neon,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: SpiderTheme.colorsFor(context).neonGlow,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'VPN Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Token input card
                GlassContainer(
                  blur: 12,
                  child: Column(
                    children: [
                      TextField(
                        controller: _tokenController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Backend Token',
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            color: SpiderTheme.colorsFor(context).neon,
                          ),
                          filled: true,
                          fillColor: Colors.white.withAlpha(15),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _connect,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Connect'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  GlassContainer(
                    customColor: Colors.red,
                    blur: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[200], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}