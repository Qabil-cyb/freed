import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _setupUrlController = TextEditingController();
  final _backendTokenController = TextEditingController();
  final _panelDomainController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _useManualEntry = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final savedUrl = await _storage.read(key: 'setup_url');
    final savedToken = await _storage.read(key: 'backend_token');
    final savedDomain = await _storage.read(key: 'panel_domain');
    if (savedUrl != null) _setupUrlController.text = savedUrl;
    if (savedToken != null) _backendTokenController.text = savedToken;
    if (savedDomain != null) _panelDomainController.text = savedDomain;
  }

  final _storage = const FlutterSecureStorage();

  Future<void> _connectWithServiceDiscovery() async {
    final setupUrl = _setupUrlController.text.trim();
    if (setupUrl.isEmpty) {
      setState(() => _errorMessage = 'Please enter Setup URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ApiService().discoverBackend(setupUrl);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success && response.data != null) {
        final setupInfo = response.data!;

        // Save all credentials
        await _storage.write(key: 'setup_url', value: setupUrl);
        await _storage.write(key: 'backend_token', value: setupInfo.backendToken);
        await _storage.write(key: 'backend_url', value: setupInfo.apiUrl);
        if (setupInfo.panelDomain != null) {
          await _storage.write(key: 'panel_domain', value: setupInfo.panelDomain);
        }

        setState(() {
          _successMessage = 'Connected successfully!';
          _backendTokenController.text = setupInfo.backendToken;
          _panelDomainController.text = setupInfo.panelDomain ?? '';
        });

        // If we got an API key, auto-login
        if (setupInfo.apiKey != null && setupInfo.apiKey!.isNotEmpty) {
          await _storage.write(key: 'api_key', value: setupInfo.apiKey);
          // Navigate to home
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomeScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        } else {
          // Switch to manual token entry
          setState(() => _useManualEntry = true);
        }
      } else {
        setState(() => _errorMessage = response.message ?? 'Discovery failed. Try manual entry.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _connectManually() async {
    final token = _backendTokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Backend Token');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ApiService().setup(token);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success) {
        // Save credentials
        await _storage.write(key: 'backend_token', value: token);
        if (_panelDomainController.text.isNotEmpty) {
          await _storage.write(key: 'panel_domain', value: _panelDomainController.text);
        }

        setState(() => _successMessage = 'Connected! Redirecting...');

        // Navigate to login screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = response.message ?? 'Setup failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _useManualEntry = !_useManualEntry;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  void dispose() {
    _setupUrlController.dispose();
    _backendTokenController.dispose();
    _panelDomainController.dispose();
    super.dispose();
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
                      Text(
                        _useManualEntry ? 'Manual Connection' : 'Service Discovery',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Service Discovery Mode
                if (!_useManualEntry) ...[
                  GlassContainer(
                    blur: 12,
                    child: Column(
                      children: [
                        // Setup URL input
                        TextField(
                          controller: _setupUrlController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Setup URL (https://panel.example.com/setup)',
                            prefixIcon: Icon(Icons.link, color: SpiderTheme.colorsFor(context).neon),
                            filled: true,
                            fillColor: Colors.white.withAlpha(15),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        // Panel Domain input
                        TextField(
                          controller: _panelDomainController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Panel Domain (optional)',
                            prefixIcon: Icon(Icons.dns, color: SpiderTheme.colorsFor(context).neon),
                            filled: true,
                            fillColor: Colors.white.withAlpha(15),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Connect button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _connectWithServiceDiscovery,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Connect'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Switch to manual mode
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            'Use Backend Token manually',
                            style: TextStyle(color: SpiderTheme.colorsFor(context).neon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Manual Connection Mode
                if (_useManualEntry) ...[
                  GlassContainer(
                    blur: 12,
                    child: Column(
                      children: [
                        // Backend Token input
                        TextField(
                          controller: _backendTokenController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Backend Token',
                            prefixIcon: Icon(Icons.vpn_key, color: SpiderTheme.colorsFor(context).neon),
                            filled: true,
                            fillColor: Colors.white.withAlpha(15),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        // Panel Domain input
                        TextField(
                          controller: _panelDomainController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Panel Domain (optional)',
                            prefixIcon: Icon(Icons.dns, color: SpiderTheme.colorsFor(context).neon),
                            filled: true,
                            fillColor: Colors.white.withAlpha(15),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Connect button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _connectManually,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Connect'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Switch to discovery mode
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            'Use Service Discovery URL',
                            style: TextStyle(color: SpiderTheme.colorsFor(context).neon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Success message
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  GlassContainer(
                    blur: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

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

                // Info text
                const SizedBox(height: 24),
                Text(
                  'No hardcoded API URL required',
                  style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'App connects via Setup URL or Backend Token',
                  style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}