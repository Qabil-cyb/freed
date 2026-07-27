import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class ProxyScreen extends StatefulWidget {
  const ProxyScreen({super.key});
  @override
  State<ProxyScreen> createState() => _ProxyScreenState();
}

class _ProxyScreenState extends State<ProxyScreen> {
  List _proxies = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    final data = await api.getProxies();
    setState(() { _proxies = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
        : _proxies.isEmpty
            ? const Center(child: Text('No proxies', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _proxies.length,
                itemBuilder: (ctx, i) => GlassCard(
                  child: Row(children: [
                    Icon(Icons.language_rounded, color: const Color(0xFF6C63FF)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_proxies[i]['country'] ?? '', style: const TextStyle(color: Colors.white))),
                    Text('${_proxies[i]['ip'] ?? ""}:${_proxies[i]['port'] ?? ""}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ),
              );
  }
}
