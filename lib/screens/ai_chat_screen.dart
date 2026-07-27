import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _send() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _msgCtrl.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _loading = true;
    });

    final api = context.read<ApiService>();
    final resp = await api.chatAI(msg);

    setState(() {
      _loading = false;
      if (resp != null && resp['response'] != null) {
        _messages.add({'role': 'ai', 'content': resp['response']});
      } else {
        _messages.add({'role': 'ai', 'content': resp?['error'] ?? 'Error connecting to AI'});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: _messages.isEmpty
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 64, color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Ask me anything', style: TextStyle(color: Colors.white38)),
                ],
              ))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                controller: _scrollCtrl,
                itemBuilder: (ctx, i) => _chatBubble(_messages[i]),
              ),
      ),
      if (_loading) const Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(color: Color(0xFF6C63FF), strokeWidth: 2),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03)),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Type your message...', border: InputBorder.none),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF6C63FF)),
            onPressed: _send,
          ),
        ]),
      ),
    ]);
  }

  Widget _chatBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Text(msg['content'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}
