import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:spider_vpn/services/api_service.dart';

class AITab extends StatefulWidget {
  const AITab({super.key});

  @override
  State<AITab> createState() => _AITabState();
}

class _AITabState extends State<AITab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isAiEnabled = false;
  bool _isLoading = false;
  bool _showBlurOverlay = false;
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showBlur = _scrollController.hasClients &&
        _scrollController.offset > 100;
    if (showBlur != _showBlurOverlay) {
      setState(() => _showBlurOverlay = showBlur);
    }
  }

  void _toggleAi() {
    setState(() {
      _isAiEnabled = !_isAiEnabled;
      if (_isAiEnabled) {
        _messages.add(ChatMessage(
          text: 'Hello! I am Hermes AI assistant. How can I help you with your Spider VPN Panel?',
          isUser: false,
          time: DateTime.now(),
        ));
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final api = ApiService.instance;
      final history = _messages
          .where((m) => m != _messages.last)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final result = await api.sendAiMessage(
        message: text,
        history: history,
        apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
      );

      final reply = result['response']?.toString() ?? result['message']?.toString() ?? 'No response from AI';

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: reply,
            isUser: false,
            time: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error connecting to AI: ${e.toString()}',
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI Toggle Button at center top
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: GestureDetector(
              onTap: _toggleAi,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: _isAiEnabled
                        ? [AppColors.neonGreen.withOpacity(0.4), AppColors.neonBlue.withOpacity(0.4)]
                        : [AppColors.glassLight.withOpacity(0.15), AppColors.glassLight.withOpacity(0.08)],
                  ),
                  border: Border.all(
                    color: _isAiEnabled
                        ? AppColors.neonGreen.withOpacity(0.6)
                        : AppColors.glassBorder.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: _isAiEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAiEnabled ? Icons.psychology_rounded : Icons.psychology_outlined,
                      color: _isAiEnabled ? AppColors.neonGreen : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isAiEnabled ? 'Hermes AI - Active' : 'Turn On Hermes AI',
                      style: TextStyle(
                        color: _isAiEnabled ? Colors.white : AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // API Key field (shown when AI is off)
        if (!_isAiEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassInputField(
              controller: _apiKeyController,
              hintText: 'Google AI Studio API Key',
              prefixIcon: Icons.key_rounded,
              suffixIcon: IconButton(
                icon: Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: AppColors.bgDarkCard.withOpacity(0.95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.glassBorder.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'API Key',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter your Google AI Studio API key to enable Hermes AI features.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            GlassButton(
                              label: 'Got it',
                              onPressed: () => Navigator.pop(ctx),
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Chat area
        if (_isAiEnabled)
          Expanded(
            child: Stack(
              children: [
                // Messages list
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.neonBlue,
                              child: Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.neonBlue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),

                // Blur overlay at top
                if (_showBlurOverlay)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.bgDark.withOpacity(0.9),
                            AppColors.bgDark.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Image upload FAB
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image upload coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 30,
                      child: Icon(Icons.image_rounded, color: AppColors.neonPurple, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_outlined, color: AppColors.textSecondary.withOpacity(0.4), size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'AI Assistant is off',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button above to enable Hermes AI',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // Message input
        if (_isAiEnabled)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.glassBorder.withOpacity(0.15)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassInputField(
                    controller: _messageController,
                    hintText: 'Type a message...',
                    prefixIcon: Icons.chat_bubble_outline_rounded,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 30,
                  onTap: _messageController.text.trim().isNotEmpty ? _sendMessage : null,
                  child: Icon(
                    Icons.send_rounded,
                    color: _messageController.text.trim().isNotEmpty
                        ? AppColors.neonBlue
                        : AppColors.textSecondary.withOpacity(0.4),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonBlue.withOpacity(0.6),
                    AppColors.neonPurple.withOpacity(0.6),
                  ],
                ),
                border: Border.all(color: AppColors.neonBlue.withOpacity(0.4), width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(msg.text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: msg.isUser ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  gradient: msg.isUser
                      ? LinearGradient(
                          colors: [
                            AppColors.neonBlue.withOpacity(0.3),
                            AppColors.neonPurple.withOpacity(0.2),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            msg.isError
                                ? AppColors.danger.withOpacity(0.15)
                                : AppColors.glassLight.withOpacity(0.1),
                            msg.isError
                                ? AppColors.danger.withOpacity(0.08)
                                : AppColors.glassLight.withOpacity(0.05),
                          ],
                        ),
                  border: Border.all(
                    color: msg.isUser
                        ? AppColors.neonBlue.withOpacity(0.4)
                        : msg.isError
                            ? AppColors.danger.withOpacity(0.3)
                            : AppColors.glassBorder.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isError ? AppColors.danger : Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(msg.time),
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                        if (msg.isUser) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.done_rounded, color: AppColors.neonGreen, size: 12),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonGreen.withOpacity(0.5),
                    AppColors.neonBlue.withOpacity(0.5),
                  ],
                ),
                border: Border.all(color: AppColors.neonGreen.withOpacity(0.4), width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}
