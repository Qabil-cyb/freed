import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'dashboard_tab.dart';
import 'inbounds_tab.dart';
import 'users_tab.dart';
import 'scanner_tab.dart';
import 'settings_screen.dart';
import 'contact_screen.dart';
import 'profile_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    DashboardTab(),
    InboundsTab(),
    UsersTab(),
    ScannerTab(),
    SettingsScreen(),
    ContactScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dns),
      label: 'Inbounds',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Users',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.scan_text),
      label: 'Scanner',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.contact_mail),
      label: 'Contact',
    ),
  ];

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _closeDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Theme(
      data: SpiderTheme.buildTheme(settingsProvider.theme),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: GalaxyBackground(
          child: Stack(
            children: [
              // Main content
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: MediaQuery.of(context).size.width > 600
                    ? const EdgeInsets.only(left: 300)
                    : EdgeInsets.zero,
                child: _screens[_selectedIndex],
              ),
              
              // Profile sidebar for large screens
              if (MediaQuery.of(context).size.width > 600)
                ProfileSidebar(
                  isOpen: _isDrawerOpen,
                  onClose: _closeDrawer,
                ),
              
              // Mobile drawer overlay
              if (!_isDrawerOpen && MediaQuery.of(context).size.width <= 600)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _toggleDrawer,
                    behavior: HitTestBehavior.opaque,
                    child: const ColoredBox(
                      color: Colors.black54,
                      child: SizedBox(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width <= 600
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: SpiderTheme.colorsFor(context).neon,
                unselectedItemColor: Colors.white54,
                items: _bottomNavItems,
              )
            : null,
        floatingActionButton: MediaQuery.of(context).size.width <= 600
            ? FloatingActionButton(
                onPressed: _toggleDrawer,
                backgroundColor: SpiderTheme.colorsFor(context).neon,
                child: const Icon(Icons.menu, color: Colors.white),
              )
            : null,
      ),
    );
  }
}