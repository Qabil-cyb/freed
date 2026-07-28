import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';

class InboundsTab extends StatefulWidget {
  const InboundsTab({super.key});

  @override
  State<InboundsTab> createState() => _InboundsTabState();
}

class _InboundsTabState extends State<InboundsTab> {
  List<Inbound> _inbounds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInbounds();
  }

  Future<void> _loadInbounds() async {
    try {
      final apiKey = await ApiService().getApiKey();
      if (apiKey != null) {
        final res = await ApiService().getInbounds(apiKey);
        if (res.success && res.data != null) {
          setState(() => _inbounds = res.data!);
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAddModal() {
    final _remarkCtrl = TextEditingController();
    final _portCtrl = TextEditingController(text: '443');
    final _ipCtrl = TextEditingController();
    final _proxyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        child: GlassContainer(
          width: double.maxFinite,
          blur: 15,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add Inbound", style: TextStyle(color: SpiderTheme.colorsFor(context).neon, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildField(_remarkCtrl, "Remark"),
                const SizedBox(height: 12),
                _buildField(_portCtrl, "Port (default 443)"),
                const SizedBox(height: 12),
                _buildField(_ipCtrl, "IP / Domain"),
                const SizedBox(height: 12),
                _buildField(_proxyCtrl, "Proxy IP"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel"))),
                    Expanded(child: ElevatedButton(onPressed: () async {
                      final inbound = Inbound(id: '', remark: _remarkCtrl.text, port: int.tryParse(_portCtrl.text) ?? 443, ipDomain: _ipCtrl.text, proxyIp: _proxyCtrl.text, enable: true, protocol: 'vless', security: 'tls');
                      final apiKey = await ApiService().getApiKey();
                      if (apiKey != null) await ApiService().addInbound(apiKey, inbound);
                      Navigator.pop(ctx);
                      _loadInbounds();
                    }, child: const Text("Create"))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white54)),
    );
  }

  void _showIpModal(Inbound inbound) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        child: GlassContainer(
          width: double.maxFinite,
          blur: 15,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("IP Selection", style: TextStyle(color: SpiderTheme.colorsFor(context).neon, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _ipOption(ctx, "Use Domain", inbound.ipDomain, inbound),
              const SizedBox(height: 8),
              _ipOption(ctx, "MCI", "104.16.0.1", inbound),
              const SizedBox(height: 8),
              _ipOption(ctx, "MTN", "104.24.0.1", inbound),
              const SizedBox(height: 8),
              _ipOption(ctx, "RTL", "172.64.0.1", inbound),
              const SizedBox(height: 8),
              _ipOption(ctx, "ADSL", "104.28.0.1", inbound),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _ipOption(BuildContext ctx, String label, String ip, Inbound inbound) {
    return TextButton(onPressed: () {
      Navigator.pop(ctx);
    }, child: Text(label, style: TextStyle(color: SpiderTheme.colorsFor(ctx).neon)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(onPressed: _showAddModal, backgroundColor: colors.neon, child: const Icon(Icons.add, color: Colors.white)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _inbounds.isEmpty
              ? Center(child: Text("No inbounds", style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inbounds.length,
                  itemBuilder: (ctx, i) {
                    final inbound = _inbounds[i];
                    return GlassContainer(
                      margin: const EdgeInsets.only(bottom: 12),
                      blur: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inbound.remark, style: TextStyle(color: colors.neon, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Port: ${inbound.port}", style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("IP/Domain: ${inbound.ipDomain}", style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _showIpModal(inbound),
                            child: Text("Proxy IP: ${inbound.proxyIp}", style: TextStyle(color: colors.neon, decoration: TextDecoration.underline)),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            TextButton(onPressed: () {}, child: Text("Edit", style: TextStyle(color: colors.neon))),
                            TextButton(onPressed: () async {
                              final apiKey = await ApiService().getApiKey();
                              if (apiKey != null) await ApiService().deleteInbound(apiKey, inbound.id);
                              _loadInbounds();
                            }, child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
