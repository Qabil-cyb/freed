import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:spider_vpn/services/api_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isLoading = false;
  final TextEditingController _botTokenCtrl = TextEditingController();
  final TextEditingController _adminChatCtrl = TextEditingController();
  final TextEditingController _apiKeyNameCtrl = TextEditingController();
  final TextEditingController _apiKeyValueCtrl = TextEditingController();
  final TextEditingController _apiKeyUrlCtrl = TextEditingController();
  final TextEditingController _resetPasswordCtrl = TextEditingController();
  List<dynamic> _apiKeys = [];

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  @override
  void dispose() {
    _botTokenCtrl.dispose();
    _adminChatCtrl.dispose();
    _apiKeyNameCtrl.dispose();
    _apiKeyValueCtrl.dispose();
    _apiKeyUrlCtrl.dispose();
    _resetPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApiKeys() async {
    try {
      final keys = await ApiService.instance.getApiKeys();
      if (mounted) setState(() => _apiKeys = keys);
    } catch (e) {
      // Silently fail
    }
  }

  void _showApiKeyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: AppColors.bgDarkCard.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorder.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add API Key',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GlassInputField(
                      controller: _apiKeyNameCtrl,
                      hintText: 'Key Name (e.g., Main Panel)',
                      prefixIcon: Icons.label_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    GlassInputField(
                      controller: _apiKeyUrlCtrl,
                      hintText: 'Panel URL',
                      prefixIcon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 14),
                    GlassInputField(
                      controller: _apiKeyValueCtrl,
                      hintText: 'API Key',
                      prefixIcon: Icons.vpn_key_rounded,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassButton(
                label: 'Save API Key',
                icon: Icons.save_rounded,
                width: double.infinity,
                onPressed: () async {
                  if (_apiKeyNameCtrl.text.isEmpty || _apiKeyValueCtrl.text.isEmpty) return;
                  Navigator.pop(context);
                  try {
                    await ApiService.instance.addApiKey(
                      name: _apiKeyNameCtrl.text,
                      panelUrl: _apiKeyUrlCtrl.text.isNotEmpty ? _apiKeyUrlCtrl.text : 'http://localhost',
                      apiKey: _apiKeyValueCtrl.text,
                    );
                    _loadApiKeys();
                    _apiKeyNameCtrl.clear();
                    _apiKeyUrlCtrl.clear();
                    _apiKeyValueCtrl.clear();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTelegramBotDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: AppColors.bgDarkCard.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorder.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Setup Telegram Bot',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GlassInputField(
                      controller: _botTokenCtrl,
                      hintText: 'Bot API Token',
                      prefixIcon: Icons.key_rounded,
                    ),
                    const SizedBox(height: 14),
                    GlassInputField(
                      controller: _adminChatCtrl,
                      hintText: 'Admin Chat ID',
                      prefixIcon: Icons.chat_rounded,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get your bot token from @BotFather and chat ID from @userinfobot',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassButton(
                label: 'Setup Bot',
                icon: Icons.check_rounded,
                width: double.infinity,
                isLoading: _isLoading,
                onPressed: () async {
                  if (_botTokenCtrl.text.isEmpty || _adminChatCtrl.text.isEmpty) return;
                  setState(() => _isLoading = true);
                  Navigator.pop(context);
                  try {
                    await ApiService.instance.setupTelegramBot(
                      _botTokenCtrl.text,
                      _adminChatCtrl.text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Telegram bot setup successfully!'),
                          backgroundColor: AppColors.neonGreen,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                      );
                    }
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPanelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgDarkCard.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.glassBorder.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withOpacity(0.15),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Icon(Icons.warning_rounded, color: AppColors.danger, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset Panel',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'This will reset all settings to default. This action cannot be undone.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GlassInputField(
                controller: _resetPasswordCtrl,
                hintText: 'Type "RESET" to confirm',
                prefixIcon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      label: 'Reset Panel',
                      primaryColor: AppColors.danger,
                      onPressed: () async {
                        if (_resetPasswordCtrl.text != 'RESET') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please type RESET to confirm'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await ApiService.instance.resetPanel({'confirm': true});
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Panel reset successfully'),
                                backgroundColor: AppColors.neonGreen,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                            );
                          }
                        }
                      },
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.settings_rounded, color: AppColors.neonBlue, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === Theme Selection ===
              _buildSectionTitle('Theme', Icons.palette_rounded),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildThemeOption(
                    'red_neon',
                    'Red Neon',
                    AppColors.neonRed,
                    settingsProvider.selectedTheme,
                    (val) => settingsProvider.setTheme(val),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildThemeOption(
                    'blue_neon',
                    'Blue Neon',
                    AppColors.neonBlue,
                    settingsProvider.selectedTheme,
                    (val) => settingsProvider.setTheme(val),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildThemeOption(
                    'green_neon',
                    'Green Neon',
                    AppColors.neonGreen,
                    settingsProvider.selectedTheme,
                    (val) => settingsProvider.setTheme(val),
                  )),
                ],
              ),

              const SizedBox(height: 24),

              // === API Keys ===
              _buildSectionTitle('API Keys', Icons.vpn_key_rounded),
              const SizedBox(height: 8),
              ...(_apiKeys.isNotEmpty
                  ? _apiKeys.map((key) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key['name']?.toString() ?? 'Key',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${key['panel_url'] ?? ''}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 20),
                          ],
                        ),
                      ),
                    ))
                  : []),
              GlassButton(
                label: 'Add API Key',
                icon: Icons.add_rounded,
                onPressed: _showApiKeyDialog,
                width: double.infinity,
              ),

              const SizedBox(height: 24),

              // === Telegram Bot ===
              _buildSectionTitle('Telegram Bot', Icons.telegram_rounded),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure your Telegram bot for notifications and panel management.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    GlassButton(
                      label: 'Setup Telegram Bot',
                      icon: Icons.telegram_rounded,
                      onPressed: _showTelegramBotDialog,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === Password Protection ===
              _buildSectionTitle('Security', Icons.security_rounded),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Require Password on Login',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Additional layer of security for your panel',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settingsProvider.requirePasswordOnLogin,
                      onChanged: (val) => settingsProvider.setRequirePassword(val),
                      activeColor: AppColors.neonBlue,
                      activeTrackColor: AppColors.neonBlue.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === Panel Reset ===
              _buildSectionTitle('Danger Zone', Icons.warning_rounded),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 14,
                borderColor: AppColors.danger.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset Panel',
                      style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permanently reset all settings to factory defaults',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    GlassButton(
                      label: 'Reset Panel',
                      icon: Icons.restart_alt_rounded,
                      primaryColor: AppColors.danger,
                      onPressed: _showResetPanelDialog,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Spider VPN Panel v1.0.0',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Powered by Xray Core',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
      String themeKey, String label, Color color, String currentTheme, Function(String) onTap) {
    final isSelected = currentTheme == themeKey;
    return GestureDetector(
      onTap: () => onTap(themeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(isSelected ? 0.25 : 0.08),
              color.withOpacity(isSelected ? 0.15 : 0.04),
            ],
          ),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder.withOpacity(0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Column(
          children: [
            // Custom SVG icon using CustomPaint
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Center(
                child: Icon(
                  themeKey == 'red_neon'
                      ? Icons.color_lens_rounded
                      : themeKey == 'green_neon'
                          ? Icons.eco_rounded
                          : Icons.water_drop_rounded,
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
