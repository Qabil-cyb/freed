import 'package:flutter/material.dart';

class GlassAppBar extends AppBar {
  GlassAppBar({super.key, required String title, List<Widget>? actions})
      : super(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white.withOpacity(0.05),
          elevation: 0,
          actions: actions,
        );
}
