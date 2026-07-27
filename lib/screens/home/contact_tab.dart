import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';

class ContactTab extends StatefulWidget {
  const ContactTab({super.key});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.contact_support_rounded, color: AppColors.neonBlue, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Contact & Support',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get in touch with the developer and join our community',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // === Developer Box ===
          _buildSectionTitle('Developer', Icons.code_rounded),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                borderColor: AppColors.neonBlue.withOpacity(0.3 + (0.3 * _glowAnimation.value)),
                child: Column(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.neonBlue.withOpacity(0.5),
                            AppColors.neonPurple.withOpacity(0.5),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.neonBlue.withOpacity(0.3 + (0.4 * _glowAnimation.value)),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonBlue.withOpacity(0.2 * _glowAnimation.value),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Amir',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Developer & Maintainer',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),

                    const SizedBox(height: 20),

                    // GitHub link
                    _buildSocialLink(
                      icon: _buildGitHubIcon(60),
                      label: 'GitHub',
                      url: 'https://github.com/amirappleidfd-stack',
                      color: AppColors.github,
                      glowColor: AppColors.neonBlue,
                    ),
                    const SizedBox(height: 12),

                    // Telegram link
                    _buildSocialLink(
                      icon: _buildTelegramIcon(60),
                      label: 'Telegram',
                      url: 'https://t.me/g1thub',
                      color: AppColors.telegram,
                      glowColor: AppColors.neonBlue,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // === Channel Box ===
          _buildSectionTitle('Channel', Icons.campaign_rounded),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                borderColor: AppColors.neonBlue.withOpacity(0.3 + (0.3 * _glowAnimation.value)),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.telegram.withOpacity(0.5),
                            AppColors.neonBlue.withOpacity(0.5),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.telegram.withOpacity(0.3 + (0.4 * _glowAnimation.value)),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.telegram.withOpacity(0.2 * _glowAnimation.value),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildTelegramIcon(40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Spider VPN Channel',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updates, news, and community discussions',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    _buildSocialLink(
                      icon: _buildTelegramIcon(24),
                      label: 'Join @spider_vpn1',
                      url: 'https://t.me/spider_vpn1',
                      color: AppColors.telegram,
                      glowColor: AppColors.telegram,
                      isChannel: true,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Footer message
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            borderColor: AppColors.neonGreen.withOpacity(0.2),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: AppColors.neonRed, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thank you for using Spider VPN Panel! '
                    'Your support and feedback drive our development.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSocialLink({
    required Widget icon,
    required String label,
    required String url,
    required Color color,
    required Color glowColor,
    bool isChannel = false,
  }) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link copied: $url'),
            backgroundColor: AppColors.neonGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15 + (0.1 * _glowAnimation.value)),
                  color.withOpacity(0.08 + (0.05 * _glowAnimation.value)),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.3 + (0.2 * _glowAnimation.value)),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.15 * _glowAnimation.value),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChannel ? 'Telegram Channel' : label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        url,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  color: color.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGitHubIcon(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GitHubIconPainter(),
    );
  }

  Widget _buildTelegramIcon(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TelegramIconPainter(),
    );
  }
}

class _GitHubIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // GitHub Octocat simplified SVG path
    final s = size.width / 24; // scale factor based on 24x24 viewBox

    // GitHub logo path
    path.moveTo(12 * s, 0 * s);
    path.cubicTo(5.37 * s, 0 * s, 0 * s, 5.37 * s, 0 * s, 12 * s);
    path.cubicTo(0 * s, 17.31 * s, 3.44 * s, 21.8 * s, 8.21 * s, 23.39 * s);
    path.cubicTo(8.81 * s, 23.5 * s, 9.03 * s, 23.14 * s, 9.03 * s, 22.83 * s);
    path.cubicTo(9.03 * s, 22.56 * s, 9.02 * s, 21.78 * s, 9.01 * s, 20.76 * s);
    path.cubicTo(5.67 * s, 21.48 * s, 4.97 * s, 19.17 * s, 4.97 * s, 19.17 * s);
    path.cubicTo(4.42 * s, 17.78 * s, 3.62 * s, 17.41 * s, 3.62 * s, 17.41 * s);
    path.cubicTo(2.49 * s, 16.66 * s, 3.7 * s, 16.68 * s, 3.7 * s, 16.68 * s);
    path.cubicTo(4.94 * s, 16.76 * s, 5.58 * s, 17.94 * s, 5.58 * s, 17.94 * s);
    path.cubicTo(6.62 * s, 19.77 * s, 8.32 * s, 19.24 * s, 9.06 * s, 18.95 * s);
    path.cubicTo(9.17 * s, 18.18 * s, 9.48 * s, 17.66 * s, 9.82 * s, 17.36 * s);
    path.cubicTo(7.15 * s, 17.04 * s, 4.36 * s, 16.01 * s, 4.36 * s, 11.39 * s);
    path.cubicTo(4.36 * s, 10.08 * s, 4.79 * s, 9.01 * s, 5.52 * s, 8.18 * s);
    path.cubicTo(5.4 * s, 7.86 * s, 5.03 * s, 6.64 * s, 5.65 * s, 5 * s);
    path.cubicTo(5.65 * s, 5 * s, 6.64 * s, 4.66 * s, 9.02 * s, 6.19 * s);
    path.cubicTo(9.95 * s, 5.92 * s, 10.97 * s, 5.78 * s, 12 * s, 5.78 * s);
    path.cubicTo(13.03 * s, 5.78 * s, 14.05 * s, 5.92 * s, 14.98 * s, 6.19 * s);
    path.cubicTo(17.36 * s, 4.66 * s, 18.35 * s, 5 * s, 18.35 * s, 5 * s);
    path.cubicTo(18.97 * s, 6.64 * s, 18.6 * s, 7.86 * s, 18.48 * s, 8.18 * s);
    path.cubicTo(19.21 * s, 9.01 * s, 19.64 * s, 10.08 * s, 19.64 * s, 11.39 * s);
    path.cubicTo(19.64 * s, 16.02 * s, 16.84 * s, 17.04 * s, 14.16 * s, 17.36 * s);
    path.cubicTo(14.58 * s, 17.72 * s, 14.96 * s, 18.42 * s, 14.96 * s, 19.5 * s);
    path.cubicTo(14.96 * s, 21.03 * s, 14.94 * s, 22.23 * s, 14.94 * s, 22.83 * s);
    path.cubicTo(14.94 * s, 23.14 * s, 15.16 * s, 23.51 * s, 15.77 * s, 23.39 * s);
    path.cubicTo(20.56 * s, 21.8 * s, 24 * s, 17.31 * s, 24 * s, 12 * s);
    path.cubicTo(24 * s, 5.37 * s, 18.63 * s, 0 * s, 12 * s, 0 * s);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TelegramIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final s = size.width / 24;

    // Telegram logo path
    path.moveTo(9.42 * s, 15.18 * s);
    path.lineTo(18.215 * s, 5.935 * s);
    path.cubicTo(18.45 * s, 5.7 * s, 18.45 * s, 5.32 * s, 18.215 * s, 5.085 * s);
    path.cubicTo(17.98 * s, 4.85 * s, 17.6 * s, 4.85 * s, 17.365 * s, 5.085 * s);
    path.lineTo(5.065 * s, 11.57 * s);
    path.cubicTo(4.83 * s, 11.805 * s, 4.83 * s, 12.185 * s, 5.065 * s, 12.42 * s);
    path.lineTo(8.57 * s, 14.225 * s);
    path.lineTo(12.59 * s, 17.75 * s);
    path.cubicTo(12.825 * s, 17.985 * s, 13.205 * s, 17.985 * s, 13.44 * s, 17.75 * s);
    path.lineTo(15.245 * s, 14.245 * s);
    path.lineTo(19.75 * s, 19.25 * s);
    path.cubicTo(19.985 * s, 19.485 * s, 20.365 * s, 19.485 * s, 20.6 * s, 19.25 * s);
    path.cubicTo(20.835 * s, 19.015 * s, 20.835 * s, 18.635 * s, 20.6 * s, 18.4 * s);
    path.lineTo(9.42 * s, 15.18 * s);
    path.close();

    // Fill with white
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
