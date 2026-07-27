import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'inbounds_screen.dart';
import 'ai_chat_screen.dart';
import 'news_screen.dart';
import 'proxy_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _pages = const [DashboardScreen(), UsersScreen(), InboundsScreen(), AiChatScreen(), NewsScreen(), ProxyScreen(), SettingsScreen()];
  final _titles = ['Dashboard','Users','Inbounds','AI','News','Proxy','Settings'];
  final _icons = [Icons.dashboard_rounded,Icons.people_rounded,Icons.cable_rounded,Icons.auto_awesome_rounded,Icons.newspaper_rounded,Icons.language_rounded,Icons.settings_rounded];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
          child: SafeArea(
            child: Row(children: [
              const SizedBox(width: 16),
              const CircleAvatar(radius: 16, backgroundColor: Color(0xFF6C63FF), child: Text('🕷️', style: TextStyle(fontSize: 16))),
              const SizedBox(width: 8),
              Text(_titles[_tab], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.person_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            ]),
          ),
        ),
      ),
    ),
    body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)])), child: _pages[_tab]),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: BottomNavigationBar(
        currentIndex: _tab, onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed, backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF6C63FF), unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontSize: 10), unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: List.generate(7, (i) => BottomNavigationBarItem(icon: Icon(_icons[i], size: 22), label: _titles[i])),
      ),
    ),
  );
}
