import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/home/dashboard_tab.dart';
import 'package:spider_vpn/screens/home/users_tab.dart';
import 'package:spider_vpn/screens/home/inbounds_tab.dart';
import 'package:spider_vpn/screens/home/ai_tab.dart';
import 'package:spider_vpn/screens/home/news_tab.dart';
import 'package:spider_vpn/screens/home/ip_proxy_tab.dart';
import 'package:spider_vpn/screens/home/settings_tab.dart';
import 'package:spider_vpn/screens/home/contact_tab.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  bool _isSidebarOpen = false;
  late PageController _pageController;
  
  final List<NavItem> _navItems = [
    NavItem('Dashboard', Icons.dashboard_rounded, Icons.dashboard_outlined),
    NavItem('Users', Icons.people_rounded, Icons.people_outline_rounded),
    NavItem('Inbounds', Icons.router_rounded, Icons.router_outlined),
    NavItem('AI', Icons.psychology_rounded, Icons.psychology_outlined),
    NavItem('News', Icons.article_rounded, Icons.article_outlined),
    NavItem('IP Proxy', Icons.cloud_rounded, Icons.cloud_outlined),
    NavItem('Settings', Icons.settings_rounded, Icons.settings_outlined),
    NavItem('Contact', Icons.contact_support_rounded, Icons.contact_support_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _sidebarController.forward();
      } else {
        _sidebarController.reverse();
      }
    });
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    if (_isSidebarOpen) _toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SettingsProvider>(
      builder: (context, authProvider, settingsProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Main content
              GalaxyBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      _buildTopBar(authProvider),
                      
                      // Page content
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _selectedIndex = index);
                          },
                          children: [
                            const DashboardTab(),
                            const UsersTab(),
                            const InboundsTab(),
                            const AITab(),
                            const NewsTab(),
                            const IPProxyTab(),
                            const SettingsTab(),
                            const ContactTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Sidebar overlay
              if (_isSidebarOpen)
                AnimatedBuilder(
                  animation: _sidebarAnimation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggleSidebar,
                        child: Container(
                          color: Colors.black.withOpacity(0.5 * _sidebarAnimation.value),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  width: 280 * _sidebarAnimation.value,
                                  child: _buildSidebar(authProvider),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              // Floating action button for sidebar toggle (hamburger)
              Positioned(
                top: 16,
                right: 16,
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  onTap: _toggleSidebar,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.neonBlue,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // App title
          Expanded(
            child: Text(
              _navItems[_selectedIndex].title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Profile avatar
          GestureDetector(
            onTap: () {
              // Navigate to profile or show profile dialog
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonBlue.withOpacity(0.5),
                    AppColors.neonPurple.withOpacity(0.5),
                  ],
                ),
                border: Border.all(
                  color: AppColors.neonBlue.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonBlue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  authProvider.user?.username?.isNotEmpty == true
                    ? authProvider.user!.username[0].toUpperCase()
                    : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthProvider authProvider) {
    return GlassContainer(
      margin: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
      blur: 20,
      opacity: 0.2,
      child: Column(
        children: [
          // User profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonBlue.withOpacity(0.6),
                        AppColors.neonPurple.withOpacity(0.6),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.neonBlue.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      authProvider.user?.username?.isNotEmpty == true
                        ? authProvider.user!.username[0].toUpperCase()
                        : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.user?.username ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.user?.email ?? 'admin@spiderpanel.com',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    authProvider.user?.role?.toUpperCase() ?? 'ADMIN',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.glassBorder.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return _buildSidebarItem(item, index, isSelected);
              },
            ),
          ),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassButton(
              label: 'Logout',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  _toggleSidebar();
                }
              },
              primaryColor: AppColors.danger.withOpacity(0.3),
              textColor: AppColors.danger,
              isOutlined: true,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(NavItem item, int index, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isSelected
          ? AppColors.neonBlue.withOpacity(0.2)
          : Colors.transparent,
        border: isSelected
          ? Border.all(color: AppColors.neonBlue.withOpacity(0.5), width: 1)
          : null,
        boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.neonBlue.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.neonBlue.withOpacity(0.3),
                    AppColors.neonPurple.withOpacity(0.3),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
            border: Border.all(
              color: isSelected
                ? AppColors.neonBlue.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Icon(
            isSelected ? item.activeIcon : item.icon,
            color: isSelected ? AppColors.neonBlue : AppColors.textSecondary,
            size: 22,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () => _onNavTap(index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        hoverColor: Colors.transparent,
        splashColor: AppColors.neonBlue.withOpacity(0.1),
      ),
    );
  }
}

class NavItem {
  final String title;
  final IconData activeIcon;
  final IconData icon;

  NavItem(this.title, this.activeIcon, this.icon);
}