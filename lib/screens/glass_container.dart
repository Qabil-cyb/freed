import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'theme_data.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final double blur;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.customColor,
    this.blur = 10,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SpiderTheme.colorsFor(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectivePadding = padding ?? const EdgeInsets.all(16);

    Widget glass = Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin ?? EdgeInsets.zero,
      padding: effectivePadding,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        gradient: gradient ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(customColor != null ? customColor!.alpha : 20),
            Colors.white.withAlpha(customColor != null ? (customColor!.alpha ~/ 2) : 10),
            Colors.white.withAlpha(customColor != null ? 0 : 5),
          ],
        ),
        border: Border.all(
          color: colors.neon.withAlpha(gradient != null ? 40 : 60),
          width: 0.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: colors.neonGlow.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: glass);
    }
    return glass;
  }
}
