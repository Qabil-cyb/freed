import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    final data = await api.getDashboard();
    setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    if (_data == null) return const Center(child: Text('Failed to load dashboard', style: TextStyle(color: Colors.white54)));

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _statCard('CPU', '${_data!['cpu_percent'] ?? 0}%', Icons.memory_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('RAM', '${_data!['ram_percent'] ?? 0}%', Icons.sd_storage_rounded)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _statCard('Disk', '${_data!['disk_percent'] ?? 0}%', Icons.storage_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Users', '${_data!['total_users'] ?? 0}', Icons.people_rounded)),
            ]),
            const SizedBox(height: 12),
            _statCard('Uptime', '${_data!['uptime'] ?? 0}s', Icons.access_time_rounded),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return GlassCard(
      child: Row(children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        )),
      ]),
    );
  }
}
