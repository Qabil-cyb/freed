import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        GlassCard(
          child: Row(children: [
            const Icon(Icons.link_rounded, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Expanded(child: Text(auth.baseUrl ?? 'No URL', style: const TextStyle(color: Colors.white))),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(children: [
            const Icon(Icons.key_rounded, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Expanded(child: Text('API Key: ${auth.apiKey?.substring(0, 20) ?? ""}...', style: const TextStyle(color: Colors.white))),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          onTap: () {
            auth.logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: const Row(children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Accounts', style: TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        ...auth.accounts.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            child: Row(children: [
              const Icon(Icons.account_circle_rounded, color: Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              Expanded(child: Text(entry.value['name'] ?? 'Panel', style: const TextStyle(color: Colors.white))),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded, color: Colors.orange, size: 20),
                onPressed: () {
                  auth.switchAccount(entry.key);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                onPressed: () => auth.removeAccount(entry.key),
              ),
            ]),
          ),
        )),
      ]),
    );
  }
}
