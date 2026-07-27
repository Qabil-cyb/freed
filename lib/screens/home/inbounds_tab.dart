import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/auth_provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/services/api_service.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class InboundsTab extends StatefulWidget {
  const InboundsTab({super.key});

  @override
  State<InboundsTab> createState() => _InboundsTabState();
}

class _InboundsTabState extends State<InboundsTab> with TickerProviderStateMixin {
  List<dynamic> _inbounds = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _loadInbounds();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadInbounds() async {
    setState(() => _isLoading = true);
    try {
      final inbounds = await ApiService.instance.getInbounds();
      if (mounted) {
        setState(() {
          _inbounds = inbounds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GalaxyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inbounds',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    GlassButton(
                      label: 'Add Inbound',
                      icon: Icons.add_rounded,
                      onPressed: _showAddInboundDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
                    : _error != null
                      ? _buildError()
                      : _inbounds.isEmpty
                        ? _buildEmptyState()
                        : _buildInboundsList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddInboundDialog,
        backgroundColor: AppColors.neonPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Inbound'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load inbounds', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GlassButton(label: 'Retry', icon: Icons.refresh, onPressed: _loadInbounds),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.router_outlined, color: AppColors.textSecondary, size: 64),
            const SizedBox(height: 16),
            Text('No inbounds yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Configure your Xray panel inbounds', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            GlassButton(label: 'Add Inbound', icon: Icons.add, onPressed: _showAddInboundDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildInboundsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _inbounds.length,
      itemBuilder: (context, index) {
        final inbound = _inbounds[index];
        return _buildInboundCard(inbound);
      },
    );
  }

  Widget _buildInboundCard(Map<String, dynamic> inbound) {
    final remark = inbound['remark'] ?? 'Unknown';
    final id = inbound['id']?.toString() ?? '0';
    final port = inbound['port'] as int? ?? 0;
    final protocol = inbound['protocol'] ?? 'vless';
    final security = inbound['security'] ?? 'none';
    final network = inbound['network'] ?? 'tcp';
    final isActive = inbound['is_active'] ?? true;
    final clientCount = inbound['client_count'] as int? ?? 0;
    final trafficUp = inbound['total_traffic_up'] as int? ?? 0;
    final trafficDown = inbound['total_traffic_down'] as int? ?? 0;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isActive
                      ? [AppColors.neonPurple.withOpacity(0.5), AppColors.neonBlue.withOpacity(0.5)]
                      : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.5)],
                  ),
                  border: Border.all(color: AppColors.neonPurple.withOpacity(0.5)),
                ),
                child: Center(
                  child: Icon(
                    Icons.router_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remark,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$id • $port • $protocol • $security',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.neonGreen.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? AppColors.neonGreen.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? AppColors.neonGreen : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _StatItemSmall(
                icon: Icons.people,
                label: 'Clients',
                value: clientCount.toString(),
                color: AppColors.neonBlue,
              ),
              _StatItemSmall(
                icon: Icons.upload,
                label: 'Upload',
                value: _formatBytes(trafficUp),
                color: AppColors.neonGreen,
              ),
              _StatItemSmall(
                icon: Icons.download,
                label: 'Download',
                value: _formatBytes(trafficDown),
                color: AppColors.neonPurple,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildOutboundDetails(protocol, security, network, inbound),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              _ActionIconSmall(
                icon: Icons.qr_code,
                color: AppColors.neonBlue,
                onTap: () => _showInboundQR(inbound),
              ),
              const SizedBox(width: 8),
              _ActionIconSmall(
                icon: Icons.edit,
                color: AppColors.neonPurple,
                onTap: () => _showEditInboundDialog(inbound),
              ),
              const SizedBox(width: 8),
              _ActionIconSmall(
                icon: Icons.copy,
                color: AppColors.neonGreen,
                onTap: () => _copyInboundConfig(inbound),
              ),
              const SizedBox(width: 8),
              _ActionIconSmall(
                icon: Icons.delete,
                color: AppColors.danger,
                onTap: () => _confirmDeleteInbound(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutboundDetails(String protocol, String security, String network, Map<String, dynamic> inbound) {
    final List<Map<String, dynamic>> details = [
      {'icon': Icons.tag, 'label': 'Remark', 'value': inbound['remark'] ?? '-'},
      {'icon': Icons.port, 'label': 'Port', 'value': (inbound['port'] as int?)?.toString() ?? '0'},
      {'icon': Icons.security, 'label': 'Protocol', 'value': protocol},
      {'icon': Icons.lock, 'label': 'Security', 'value': security},
      {'icon': Icons.network_cell, 'label': 'Network', 'value': network},
    ];
    
    if (security == 'tls') {
      details.add({'icon': Icons.security_update, 'label': 'SNI', 'value': inbound['tls_sni'] ?? '-'});
      details.add({'icon': Icons.http, 'label': 'Host', 'value': inbound['ws_host'] ?? '-'});
    } 
    else if (security == 'reality') {
      details.add({'icon': Icons.blur_on, 'label': 'SpiderX', 'value': inbound['external_proxy'] ?? '-'});
      details.add({'icon': Icons.key, 'label': 'Private Key', 'value': inbound['reality_private_key'] ?? '-'});
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: details.map((detail) => _buildDetailItem(detail['icon'], detail['label'], detail['value'] as String)).toList(),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('$label: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _StatItemSmall({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _ActionIconSmall({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Future<void> _showAddInboundDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddInboundDialog(),
    );
    if (result != null && mounted) {
      _loadInbounds();
    }
  }

  Future<void> _showEditInboundDialog(Map<String, dynamic> inbound) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddInboundDialog(inbound: inbound),
    );
    if (result != null && mounted) {
      _loadInbounds();
    }
  }

  void _showInboundQR(Map<String, dynamic> inbound) {
    final id = inbound['id']?.toString() ?? '0';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Inbound ID: $id', style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              QrImageView(
                data: 'xui://inbound?id=$id',
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyInboundConfig(Map<String, dynamic> inbound) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inbound config copied to clipboard')),
    );
  }

  void _confirmDeleteInbound(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgDarkCard,
        title: const Text('Delete Inbound?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
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
}

class AddInboundDialog extends StatefulWidget {
  final Map<String, dynamic>? inbound;

  const AddInboundDialog({super.key, this.inbound});

  @override
  State<AddInboundDialog> createState() => _AddInboundDialogState();
}

class _AddInboundDialogState extends State<AddInboundDialog> {
  final _formKey = GlobalKey<FormState>();
  final _remarkController = TextEditingController();
  final _portController = TextEditingController();
  String _protocol = 'vless';
  String _security = 'none';
  String _network = 'tcp';
  final _listenController = TextEditingController(text: '0.0.0.0');
  final _wsPathController = TextEditingController();
  final _grpcServiceController = TextEditingController();
  final _externalProxyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.inbound != null) {
      final inbound = widget.inbound!;
      _remarkController.text = inbound['remark'] ?? '';
      _portController.text = (inbound['port'] as int?)?.toString() ?? '';
      _protocol = inbound['protocol'] ?? 'vless';
      _security = inbound['security'] ?? 'none';
      _network = inbound['network'] ?? 'tcp';
      _listenController.text = inbound['listen'] ?? '0.0.0.0';
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _portController.dispose();
    _wsPathController.dispose();
    _grpcServiceController.dispose();
    _externalProxyController.dispose();
    _listenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return GlassContainer(
          margin: const EdgeInsets.all(16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.inbound == null ? 'Add Inbound' : 'Edit Inbound',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlassInputField(
                  label: 'Remark',
                  hint: 'e.g., VLESS - Inbound 1',
                  controller: _remarkController,
                  icon: Icons.tag,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Port',
                  hint: '40000',
                  controller: _portController,
                  icon: Icons.port,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildDropdownField('Protocol', _protocol, ['vless', 'vmess', 'trojan', 'shadowsocks']),
                const SizedBox(height: 16),
                _buildDropdownField('Security', _security, ['none', 'tls', 'reality']),
                const SizedBox(height: 16),
                _buildDropdownField('Network', _network, ['tcp', 'ws', 'grpc', 'xhttp']),
                const SizedBox(height: 24),
                _buildSectionTitle('TLS Settings', _security == 'tls' || _security == 'reality'),
                if (_security == 'tls') ...[
                  GlassInputField(
                    label: 'SNI',
                    hint: 'example.com',
                    controller: _listenController,
                    icon: Icons.http,
                  ),
                  const SizedBox(height: 16),
                  GlassInputField(
                    label: 'Host',
                    hint: 'example.com',
                    controller: _wsPathController,
                    icon: Icons.language,
                  ),
                ],
                if (_security == 'reality') ...[
                  GlassInputField(
                    label: 'SpiderX',
                    hint: 'spiderx-nl',
                    controller: _externalProxyController,
                    icon: Icons.spider_web,
                  ),
                ],
                const SizedBox(height: 24),
                GlassButton(
                  label: widget.inbound == null ? 'Add Inbound' : 'Save Changes',
                  icon: Icons.save,
                  onPressed: _isLoading ? null : _saveInbound,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              dropdownColor: AppColors.bgDarkCard,
              style: const TextStyle(color: Colors.white),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => {if (v != null) {
                if (label == 'Security') _security = v;
                if (label == 'Network') _network = v;
                if (label == 'Protocol') _protocol = v;
              }}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isActive) {
    if (!isActive) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.settings, color: AppColors.neonBlue, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.neonBlue, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _saveInbound() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
    }
  }
}