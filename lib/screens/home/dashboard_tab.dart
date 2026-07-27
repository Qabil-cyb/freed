import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:spider_vpn/services/api_service.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadStats();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService.instance;
      final result = await api.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    _refreshController.forward(from: 0);
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.neonBlue,
      backgroundColor: AppColors.bgDarkCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                GlassButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onPressed: _refresh,
                  isLoading: _isLoading,
                  width: 120,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Stats Grid
            _isLoading
              ? _buildLoadingStats()
              : _buildStatsGrid(),
            
            const SizedBox(height: 24),
            
            // System Status
            _buildSystemStatus(),
            
            const SizedBox(height: 24),
            
            // Xray Status
            _buildXrayStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: List.generate(4, (i) => _buildStatCardShimmer()),
    );
  }

  Widget _buildStatCardShimmer() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: ShimmerLoading(
        isLoading: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats ?? {};
    final cards = [
      StatCardData(
        'Total Users',
        stats['total_users']?.toString() ?? '0',
        Icons.people_rounded,
        AppColors.neonBlue,
        'users',
      ),
      StatCardData(
        'Active Users',
        stats['active_users']?.toString() ?? '0',
        Icons.circle_rounded,
        AppColors.neonGreen,
        'active',
      ),
      StatCardData(
        'Total Inbounds',
        stats['total_inbounds']?.toString() ?? '0',
        Icons.router_rounded,
        AppColors.neonPurple,
        'inbounds',
      ),
      StatCardData(
        'Active Inbounds',
        stats['active_inbounds']?.toString() ?? '0',
        Icons.check_circle_rounded,
        AppColors.neonOrange,
        'active_inbounds',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: cards.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(StatCardData data) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: () {
        // Navigate to relevant tab
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      data.color.withOpacity(0.3),
                      data.color.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: data.color.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
              child: Icon(data.icon, color: data.color, size: 24),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data.type,
                style: TextStyle(
                  color: data.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          data.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    final stats = _stats ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildSystemCard(
              'CPU Usage',
              '${stats['cpu_usage']?.toStringAsFixed(1) ?? '0.0'}%',
              Icons.memory_rounded,
              AppColors.neonBlue,
              (stats['cpu_usage'] as num? ?? 0) / 100,
            ),
            _buildSystemCard(
              'Memory',
              '${stats['memory_usage']?.toStringAsFixed(1) ?? '0.0'}%',
              Icons.storage_rounded,
              AppColors.neonPurple,
              (stats['memory_usage'] as num? ?? 0) / 100,
            ),
            _buildSystemCard(
              'Disk Usage',
              '${stats['disk_usage']?.toStringAsFixed(1) ?? '0.0'}%',
              Icons.sd_storage_rounded,
              AppColors.neonGreen,
              (stats['disk_usage'] as num? ?? 0) / 100,
            ),
            _buildSystemCard(
              'Network',
              _formatBytes(stats['network_up'] ?? 0) + ' ↑ / ' + 
              _formatBytes(stats['network_down'] ?? 0) + ' ↓',
              Icons.network_check_rounded,
              AppColors.neonOrange,
              0.5,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withOpacity(0.2),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXrayStatus() {
    final stats = _stats ?? {};
    final isRunning = stats['xray_is_running'] as bool? ?? false;
    final version = stats['xray_version']?.toString() ?? 'Unknown';
    final uptime = stats['xray_uptime'] as int? ?? 0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isRunning
                      ? [AppColors.neonGreen.withOpacity(0.3), AppColors.neonGreen.withOpacity(0.1)]
                      : [AppColors.danger.withOpacity(0.3), AppColors.danger.withOpacity(0.1)],
                  ),
                  border: Border.all(
                    color: isRunning
                      ? AppColors.neonGreen.withOpacity(0.5)
                      : AppColors.danger.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  isRunning ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: isRunning ? AppColors.neonGreen : AppColors.danger,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xray Core',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isRunning ? 'Running' : 'Stopped',
                      style: TextStyle(
                        color: isRunning ? AppColors.neonGreen : AppColors.danger,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'v$version',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Uptime: ${_formatUptime(uptime)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatUptime(int seconds) {
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (d > 0) return '${d}d ${h}h ${m}m';
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String type;

  StatCardData(this.title, this.value, this.icon, this.color, this.type);
}