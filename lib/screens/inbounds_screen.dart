import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class InboundsScreen extends StatefulWidget {
  const InboundsScreen({super.key});
  @override
  State<InboundsScreen> createState() => _InboundsScreenState();
}

class _InboundsScreenState extends State<InboundsScreen> {
  List _inbounds = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    final data = await api.getInbounds();
    setState(() { _inbounds = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _inbounds.isEmpty
              ? const Center(child: Text('No inbounds yet', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inbounds.length,
                  itemBuilder: (ctx, i) => _inboundCard(_inbounds[i]),
                ),
    );
  }

  Widget _inboundCard(dynamic ib) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.cable_rounded, color: ib['enabled'] == true ? const Color(0xFF6C63FF) : Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(ib['remark'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          Text('${ib['port']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Text('${ib['protocol']} • ${ib['security']} • ${ib['transport']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            icon: Icon(ib['enabled'] == true ? Icons.pause_circle : Icons.play_circle),
            onPressed: () async {
              final api = context.read<ApiService>();
              if (ib['enabled'] == true) {
                await api.post('/api/inbounds/${ib['id']}/disable');
              } else {
                await api.post('/api/inbounds/${ib['id']}/enable');
              }
              _load();
            },
            color: ib['enabled'] == true ? Colors.orange : Colors.green,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.red),
            onPressed: () async {
              await context.read<ApiService>().deleteInbound(ib['id']);
              _load();
            },
          ),
        ]),
      ]),
    );
  }

  void _showAddDialog() {
    final remarkCtrl = TextEditingController();
    final portCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    String protocol = 'vless';
    String security = 'reality';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setDialogState) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Create Inbound', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: remarkCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Remark')),
            const SizedBox(height: 12),
            TextField(controller: portCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Port'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: tagCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tag')),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: protocol, dropdownColor: const Color(0xFF1A1A2E), style: const TextStyle(color: Colors.white),
              items: ['vless','vmess','trojan','shadowsocks'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => protocol = v!),
            ),
            DropdownButton<String>(
              value: security, dropdownColor: const Color(0xFF1A1A2E), style: const TextStyle(color: Colors.white),
              items: ['reality','tls','none'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => security = v!),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await context.read<ApiService>().createInbound({
                    'remark': remarkCtrl.text,
                    'port': int.tryParse(portCtrl.text) ?? 443,
                    'protocol': protocol,
                    'security': security,
                    'tag': tagCtrl.text,
                  });
                  Navigator.pop(context);
                  _load();
                },
                child: const Text('Create'),
              ),
            ]),
          ]),
        ),
      )),
    );
  }
}
