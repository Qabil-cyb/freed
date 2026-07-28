import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return Scaffold(
        body: GalaxyBackground(
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    // Check if this is first launch - exactly ONE token check
    if (auth.backendToken.isEmpty) {
      return const WelcomeScreen();
    }

    return const LoginScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _SectionPlaceholder(label: 'Welcome to Spider Panel', icon: Icons.language),
    const UsersTab(),
    _SectionPlaceholder(label: 'Settings', icon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final colors = SpiderTheme.colorsFor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GalaxyBackground(
        child: Column(
          children: [
            // Top bar - clean minimal
            Container(
              height: 60,
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + title
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Icon(Icons.language, color: colors.neon, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Spider Panel',
                          style: TextStyle(
                            color: colors.neon,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(Icons.menu, color: colors.neon),
                      onPressed: () => _showProfileSidebar(context),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      // Bottom Navigation - only Users tab
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_rounded, 'Home', colors),
            _navItem(1, Icons.people_rounded, 'Users', colors),
            _navItem(2, Icons.settings_rounded, 'Settings', colors),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, ThemeColors colors) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.neon.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isSelected ? colors.neon : Colors.white54, size: 28),
      ),
    );
  }

  void _showProfileSidebar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ProfileSidebar(),
    );
  }
}

// Simple placeholder for sections that don't exist yet
class _SectionPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionPlaceholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 18)),
        ],
      ),
    );
  }
}