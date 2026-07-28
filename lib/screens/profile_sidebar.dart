import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';
class ProfileSidebar extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const ProfileSidebar({super.key, required this.isOpen, required this.onClose});

  @override
  State<ProfileSidebar> createState() => _ProfileSidebarState();
}

class _ProfileSidebarState extends State<ProfileSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ProfileInfo? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) _controller.forward(); else _controller.reverse();
  }

  Future<void> _loadProfile() async {
    try {
      final apiKey = await ApiService().getApiKey();
      if (apiKey != null) {
        final res = await ApiService().getProfile(apiKey);
        if (res.success && res.data != null) {
          setState(() { _profile = res.data; _loading = false; });
          return;
        }
      }
    } catch (_) {}
    setState(() { _profile = ProfileInfo.mock(); _loading = false; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);
    final authProvider = context.watch<AuthProvider>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-300 * (1 - _controller.value), 0),
          child: Container(
            width: 300,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xff0a0a1a), const Color(0xff121225)],
              ),
              border: Border(right: BorderSide(color: colors.neon.withAlpha(40), width: 1)),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: colors.neon.withAlpha(40),
                            child: Icon(Icons.person, size: 40, color: colors.neon),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info
                        _infoRow("Domain", _profile?.domain ?? "N/A", colors),
                        _infoRow("API Key", _profile?.apiKey ?? "N/A", colors),
                        _infoRow("Railway Token", _profile?.railwayToken ?? "N/A", colors),
                        _infoRow("Status", _profile?.accountStatus ?? "Active", colors),
                        const SizedBox(height: 16),

                        Text("Max Account Creation: ${_profile?.maxAccounts ?? 5} Accounts", style: TextStyle(color: colors.neon, fontSize: 12, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 24),

                        // Buttons
                        SizedBox(width: double.infinity, child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add),
                          label: const Text("Create Account"),
                          style: ElevatedButton.styleFrom(backgroundColor: colors.neon),
                        )),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: OutlinedButton.icon(
                          onPressed: () {
                            authProvider.logout();
                            widget.onClose();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: colors.redAccent), foregroundColor: colors.redAccent),
                        )),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.settings_backup_restore),
                          label: const Text("Reset Settings"),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: colors.orangeAccent), foregroundColor: colors.orangeAccent),
                        )),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.neon, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}