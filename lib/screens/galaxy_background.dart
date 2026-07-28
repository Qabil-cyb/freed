import 'dart:math';
import 'package:flutter/material.dart';

class GalaxyBackground extends StatefulWidget {
  final Widget child;

  const GalaxyBackground({super.key, required this.child});

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  late List<Nebula> _nebulae;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    final random = Random();
    _stars = List.generate(200, (_) => Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 2 + 0.5,
      brightness: random.nextDouble() * 0.8 + 0.2,
      twinkleSpeed: random.nextDouble() * 2 + 1,
      twinkleOffset: random.nextDouble() * pi * 2,
    ));

    _nebulae = List.generate(5, (_) => Nebula(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 200 + 100,
      color: [
        Colors.purple.withAlpha(15),
        Colors.blue.withAlpha(15),
        Colors.pink.withAlpha(10),
        Colors.teal.withAlpha(10),
        Colors.deepPurple.withAlpha(12),
      ][random.nextInt(5)],
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff050510),
                Color(0xff0a0a1a),
                Color(0xff0f0f2a),
                Color(0xff050510),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: GalaxyPainter(
              stars: _stars,
              nebulae: _nebulae,
              animationValue: _controller.value,
            ),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class Star {
  final double x, y, size, brightness, twinkleSpeed, twinkleOffset;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class Nebula {
  final double x, y, radius;
  final Color color;

  Nebula({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
  });
}

class GalaxyPainter extends CustomPainter {
  final List<Star> stars;
  final List<Nebula> nebulae;
  final double animationValue;

  GalaxyPainter({
    required this.stars,
    required this.nebulae,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw nebulae
    for (final nebula in nebulae) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [nebula.color, Colors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(nebula.x * size.width, nebula.y * size.height),
          radius: nebula.radius,
        ));
      canvas.drawCircle(
        Offset(nebula.x * size.width, nebula.y * size.height),
        nebula.radius,
        paint,
      );
    }

    // Draw stars
    for (final star in stars) {
      final twinkle = (sin(animationValue * pi * 2 * star.twinkleSpeed + star.twinkleOffset) + 1) / 2;
      final alpha = (star.brightness * (0.5 + twinkle * 0.5) * 255).toInt().clamp(0, 255);

      final paint = Paint()
        ..color = Colors.white.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter oldDelegate) => true;
}