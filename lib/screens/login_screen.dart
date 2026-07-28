import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadStoredKey();
  }

  Future<void> _loadStoredKey() async {
    final key = await ApiService().getApiKey();
    if (key != null && mounted) {
      _apiKeyController.text = key;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _enterPanel() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() => _errorMessage = 'Please enter an API Key');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService().verifyKey(key);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      setState(() => _errorMessage = response.message ?? 'Invalid API Key');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Scaffold(
      body: GalaxyBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                GlassContainer(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.only(bottom: 32),
                  blur: 15,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + _pulseController.value * 0.1,
                            child: Icon(
                              Icons.language,
                              size: 80,
                              color: colors.neon,
                            ),
                          );
                        },
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      Text(
                        'Spider Panel',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colors.neon,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: colors.neonGlow,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter Panel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                // API Key input
                GlassContainer(
                  blur: 12,
                  child: Column(
                    children: [
                      TextField(
                        controller: _apiKeyController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'API Key',
                          prefixIcon: Icon(
                            Icons.key,
                            color: colors.neon,
                          ),
                          filled: true,
                          fillColor: Colors.white.withAlpha(15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _enterPanel,
                          child: _isLoading
                              ? AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 0.8 + _pulseController.value * 0.4,
                                      child: const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Text('Enter Panel'),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2),

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
                  ).animate().shake(duration: 400.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}