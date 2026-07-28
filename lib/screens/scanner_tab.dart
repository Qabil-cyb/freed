import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';
import 'login_screen.dart';

class ScannerTab extends StatefulWidget {
  const ScannerTab({super.key});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> with SingleTickerProviderStateMixin {
  List<ScanCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchScanStatus();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchScanStatus() async {
    final authProvider = context.read<AuthProvider>();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _categories = ScanCategory.defaults(); // Use default data
    setState(() => _isLoading = false);

    // TODO: Fetch actual scan status from API
    // for (final category in _categories) {
    //   final response = await ApiService().getScanStatus(authProvider.apiKey, category.name);
    //   if (response.success && response.data != null) {
    //     _categories[_categories.indexOf(category)] = response.data!;
    //   }
    // }
  }

  Future<void> _refresh() async {
    _refreshController.forward(from: 0);
    await _fetchScanStatus();
  }

  void _showCategoryResults(ScanCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff121225),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${category.displayName} Scan Results',
          style: TextStyle(color: SpiderTheme.colorsFor(context).neon),
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: category.results.isEmpty
              ? Center(
                  child: Text(
                    'No results available',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: category.results.length,
                  itemBuilder: (context, index) {
                    final result = category.results[index];
                    return _buildScanResultCard(result);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultCard(ScanResult result) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: result.status.toLowerCase() == 'active'
                  ? Colors.green.withAlpha(30)
                  : result.status.toLowerCase() == 'slow'
                      ? Colors.orange.withAlpha(30)
                      : Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.computer,
              color: result.status.toLowerCase() == 'active'
                  ? Colors.green
                  : result.status.toLowerCase() == 'slow'
                      ? Colors.orange
                      : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.ip,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Port: ${result.port}',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TCP: ${result.tcpMs > 0 ? '${result.tcpMs}ms' : 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: result.tcpMs > 0 ? Colors.green : Colors.white54,
                ),
              ),
              Text(
                'TLS: ${result.tlsMs > 0 ? '${result.tlsMs}ms' : 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: result.tlsMs > 0 ? Colors.blue : Colors.white54,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: result.status.toLowerCase() == 'active'
                      ? Colors.green.withAlpha(30)
                      : result.status.toLowerCase() == 'slow'
                          ? Colors.orange.withAlpha(30)
                          : Colors.red.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: result.status.toLowerCase() == 'active'
                        ? Colors.green[300]
                        : result.status.toLowerCase() == 'slow'
                            ? Colors.orange[300]
                            : Colors.red[300],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          IconButton(
            icon: RotationTransition(
              turns: _refreshController,
              child: const Icon(Icons.refresh),
            ),
            onPressed: _isLoading ? null : _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.neon),
                  const SizedBox(height: 16),
                  Text('Loading scanner status...', style: TextStyle(color: colors.neon)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: GlassContainer(
                    customColor: Colors.red,
                    blur: 8,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                        const SizedBox(height: 16),
                        Text(_errorMessage!,
                            style: TextStyle(color: Colors.red[200], fontSize: 16),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchScanStatus, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: colors.neon,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryCard(category).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.2);
                    },
                  ),
                ),
    );
  }

  Widget _buildCategoryCard(ScanCategory category) {
    final colors = SpiderTheme.colorsFor(context);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.type == InboundType.mci
                      ? Colors.blue.withAlpha(30)
                      : category.type == InboundType.mtn
                          ? Colors.green.withAlpha(30)
                          : category.type == InboundType.rtl
                              ? Colors.orange.withAlpha(30)
                              : Colors.purple.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.category,
                  color: category.type == InboundType.mci
                      ? Colors.blue
                      : category.type == InboundType.mtn
                          ? Colors.green
                          : category.type == InboundType.rtl
                              ? Colors.orange
                              : Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${category.type.name.toUpperCase()} • ${category.status.name.toUpperCase()}',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryResults(category),
                icon: Icon(Icons.more_vert, color: colors.neon),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: category.status == ScanStatus.scanning ? 0.5 : 1.0,
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(
              category.status == ScanStatus.scanning
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.status == ScanStatus.scanning
                ? 'Scanning in progress...'
                : '${category.results.length} IP(s) scanned',
            style: TextStyle(
              fontSize: 12,
              color: category.status == ScanStatus.scanning ? Colors.orange : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}