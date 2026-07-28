import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'glass_container.dart';
import 'galaxy_background.dart';
import 'theme_data.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  static const String githubUrl = 'https://github.com/amirappleidfd-stack';
  static const String telegramUrl = 'https://t.me/g1itub';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Contact & Support'),
        centerTitle: true,
      ),
      body: GalaxyBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_support,
                      size: 64,
                      color: colors.neon,
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text(
                      'Get In Touch',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.neon,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      'Have questions? Need support? Connect with us through our official channels.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  ],
                ),
              ),

              // Contact Cards
              Text(
                'Official Channels',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.neon,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 16),

              // GitHub Card
              _ContactCard(
                icon: Icons.code,
                title: 'GitHub',
                subtitle: 'Repository & Issues',
                description: 'View source code, report bugs, request features, and contribute to Spider Panel.',
                color: Colors.white,
                accentColor: colors.neon,
                url: githubUrl,
                onTap: () => _launchUrl(githubUrl),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.2),

              const SizedBox(height: 16),

              // Telegram Card
              _ContactCard(
                icon: Icons.telegram,
                title: 'Telegram',
                subtitle: 'Community & Support',
                description: 'Join our Telegram channel for updates, announcements, and community support.',
                color: Colors.blueAccent,
                accentColor: Colors.blue,
                url: telegramUrl,
                onTap: () => _launchUrl(telegramUrl),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: 0.2),

              const SizedBox(height: 32),

              // Additional Info
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Resources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.neon,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ResourceItem(
                      icon: Icons.article,
                      title: 'Documentation',
                      subtitle: 'Complete setup guides and API documentation',
                      onTap: () => _launchUrl('https://github.com/amirappleidfd-stack/spider-panel/wiki'),
                    ),
                    const SizedBox(height: 12),
                    _ResourceItem(
                      icon: Icons.bug_report,
                      title: 'Report Issues',
                      subtitle: 'Found a bug? Let us know on GitHub Issues',
                      onTap: () => _launchUrl('https://github.com/amirappleidfd-stack/spider-panel/issues'),
                    ),
                    const SizedBox(height: 12),
                    _ResourceItem(
                      icon: Icons.lightbulb,
                      title: 'Feature Requests',
                      subtitle: 'Have an idea? Submit a feature request',
                      onTap: () => _launchUrl('https://github.com/amirappleidfd-stack/spider-panel/issues/new/choose'),
                    ),
                    const SizedBox(height: 12),
                    _ResourceItem(
                      icon: Icons.star,
                      title: 'Star the Project',
                      subtitle: 'Support us by starring on GitHub',
                      onTap: () => _launchUrl(githubUrl),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

              const SizedBox(height: 24),

              // Version Info
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Spider Panel v1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.neon,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VPN Management Application\nBuilt with Flutter • Powered by Xray',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color accentColor;
  final String url;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.accentColor,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Row(
        children: [
          // Icon container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withAlpha(80),
                  accentColor.withAlpha(30),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withAlpha(60),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(40),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: accentColor.withAlpha(150),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResourceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: Colors.white70),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: 18,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }
}