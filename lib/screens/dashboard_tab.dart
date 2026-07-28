import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  ServerStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final apiKey = await ApiService().getApiKey();
      if (apiKey != null) {
        final res = await ApiService().getStats(apiKey);
        if (res.success && res.data != null) {
          setState(() { _stats = res.data; _loading = false; });
          return;
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);
    final stats = _stats ?? ServerStats.mock();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Domain Card
          GlassContainer(
            width: double.infinity,
            blur: 15,
            child: Center(
              child: Text(
                stats.domain,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.neon, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Server Information
          Text("Server Information", style: TextStyle(fontSize: 14, color: colors.neon, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          GlassContainer(
            width: double.infinity,
            blur: 12,
            child: Column(
              children: [
                _infoRow("Status", stats.status ? "Online" : "Offline", colors),
                const Divider(color: Colors.white12, height: 1),
                _barRow("CPU", stats.cpuUsage, colors),
                const Divider(color: Colors.white12, height: 1),
                _barRow("RAM", stats.ramUsage, colors),
                const Divider(color: Colors.white12, height: 1),
                _infoRow("Network", stats.network, colors),
                const Divider(color: Colors.white12, height: 1),
                _infoRow("Xray Status", stats.xrayStatus, colors),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Users
          Text("Users", style: TextStyle(fontSize: 14, color: colors.neon, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          GlassContainer(
            width: double.infinity,
            blur: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn("Total", stats.totalUsers.toString(), colors.neon),
                _statColumn("Active", stats.activeUsers.toString(), Colors.greenAccent),
                _statColumn("Expired", stats.expiredUsers.toString(), Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Traffic
          Text("Traffic", style: TextStyle(fontSize: 14, color: colors.neon, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          GlassContainer(
            width: double.infinity,
            blur: 12,
            child: Column(
              children: [
                _infoRow("Total Usage", stats.totalUsage, colors),
                const Divider(color: Colors.white12, height: 1),
                _infoRow("Upload", stats.upload, colors),
                const Divider(color: Colors.white12, height: 1),
                _infoRow("Download", stats.download, colors),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: TextStyle(color: colors.neon, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _barRow(String label, double percent, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text("${percent.toStringAsFixed(1)}%", style: TextStyle(color: colors.neon, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(percent > 80 ? Colors.redAccent : percent > 50 ? Colors.orangeAccent : colors.neon),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
