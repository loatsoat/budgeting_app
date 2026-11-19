import 'package:flutter/material.dart';

// Pre-computed translucent colours shared by the overview screens, so build() never recomputes alpha.
class OverviewColors {
  // Replace: Colors.white.withValues(alpha: 0.05)
  static const white05 = Color(0x0DFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.1)
  static const white10 = Color(0x1AFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.2)
  static const white20 = Color(0x33FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.3)
  static const white30 = Color(0x4DFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.5)
  static const white50 = Color(0x80FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.6)
  static const white60 = Color(0x99FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.8)
  static const white80 = Color(0xCCFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.9)
  static const white90 = Color(0xE6FFFFFF);

  // Replace: Colors.black.withValues(alpha: 0.3)
  static const black30 = Color(0x4D000000);

  // Replace: Color(0xFF2A3B5C).withValues(alpha: 0.8)
  static const surfaceDark80 = Color(0xCC2A3B5C);
  // Replace: Color(0xFF1A1F3A).withValues(alpha: 0.8)
  static const background80 = Color(0xCC1A1F3A);
  // Replace: Color(0xFF1A1F3A).withValues(alpha: 0.5)
  static const background50 = Color(0x801A1F3A);
}
