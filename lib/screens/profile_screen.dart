import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)]),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            CircleAvatar(
              radius: 50, backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                (profile?['name'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _row('Name', profile?['name'] ?? 'Admin'),
                _row('Theme', profile?['theme'] ?? 'dark'),
                _row('API Key', '${auth.apiKey?.substring(0, 16) ?? ""}...'),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text('$label: ', style: const TextStyle(color: Colors.white54)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
      ]),
    );
  }
}
