import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List _news = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    final data = await api.getNews();
    setState(() { _news = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () async {
          await context.read<ApiService>().post('/api/news/refresh');
          _load();
        },
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _news.isEmpty
              ? const Center(child: Text('No news available', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _news.length,
                  itemBuilder: (ctx, i) => GlassCard(
                    child: Text(_news[i]['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
    );
  }
}
