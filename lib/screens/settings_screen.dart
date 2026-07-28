import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'theme_data.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _domainController;
  late TextEditingController _apiKeyController;
  late TextEditingController _railwayTokenController;
  late TextEditingController _backendUrlController;
  late TextEditingController _edgeTunnelController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _domainController = TextEditingController(text: settings.panelDomain);
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _railwayTokenController = TextEditingController(text: settings.railwayToken);
    _backendUrlController = TextEditingController(text: settings.backendUrl);
    _edgeTunnelController = TextEditingController(text: settings.edgeTunnelSettings);
  }

  @override
  void dispose() {
    _domainController.dispose();
    _apiKeyController.dispose();
    _railwayTokenController.dispose();
    _backendUrlController.dispose();
    _edgeTunnelController.dispose();
    super.dispose();
  }

  Future<void> _selectTheme(AppTheme theme) async {
    final provider = context.read<SettingsProvider>();
    await provider.updateTheme(theme);
    setState(() {});
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          blur: 15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Logout?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('This will clear all stored credentials.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _doLogout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doLogout() {
    context.read<SettingsProvider>().updateSettings(AppSettings.defaultSettings());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showResetUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          blur: 15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text('Reset All Users?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('This action cannot be undone. All users will be deleted.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          blur: 15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dangerous, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Reset Configuration?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('This will wipe all settings. Continue?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _doResetConfig();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doResetConfig() {
    context.read<SettingsProvider>().updateSettings(AppSettings.defaultSettings());
    _domainController.text = '';
    _apiKeyController.text = '';
    _railwayTokenController.text = '';
    _backendUrlController.text = 'https://api.example.com';
    _edgeTunnelController.text = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);
    final provider = context.watch<SettingsProvider>();
    final currentTheme = provider.theme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Selector
            GlassContainer(
              blur: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Theme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption(Colors.red, AppTheme.redNeon, currentTheme == AppTheme.redNeon, colors),
                      _buildThemeOption(Colors.blue, AppTheme.blueNeon, currentTheme == AppTheme.blueNeon, colors),
                      _buildThemeOption(Colors.green, AppTheme.greenNeon, currentTheme == AppTheme.greenNeon, colors),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 16),

            // Settings fields
            GlassContainer(
              blur: 15,
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _domainController,
                      decoration: const InputDecoration(
                        labelText: 'Panel Domain',
                        prefixIcon: Icon(Icons.language),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _railwayTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Railway Token',
                        prefixIcon: Icon(Icons.train),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _backendUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Backend URL',
                        prefixIcon: Icon(Icons.link),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _edgeTunnelController,
                      decoration: const InputDecoration(
                        labelText: 'Edge Tunnel Settings',
                        prefixIcon: Icon(Icons.tunnel),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

            const SizedBox(height: 16),

            // Action buttons
            GlassContainer(
              blur: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    'Logout',
                    Icons.logout,
                    Colors.red,
                    _showLogoutDialog,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Reset All Users',
                    Icons.group_remove,
                    Colors.orange,
                    _showResetUsersDialog,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Reset Configuration',
                    Icons.settings_backup_restore,
                    Colors.redAccent,
                    _showResetConfigDialog,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(Color baseColor, AppTheme theme, bool isSelected, ThemeColors colors) {
    return GestureDetector(
      onTap: () => _selectTheme(theme),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withAlpha(50),
              baseColor.withAlpha(20),
            ],
          ),
          border: Border.all(
            color: isSelected ? colors.neon : Colors.white.withAlpha(30),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.neonGlow.withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            Icons.circle,
            size: 30,
            color: baseColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}