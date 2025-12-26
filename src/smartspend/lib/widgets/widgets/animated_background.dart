import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(seconds: 15 + index * 5),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(controller))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge(_animations),
        builder: (context, child) {
          return CustomPaint(
            painter: LavaLampPainter(
              animations: _animations.map((a) => a.value).toList(),
            ),
          );
        },
      ),
    );
  }
}

class LavaLampPainter extends CustomPainter {
  final List<double> animations;

  LavaLampPainter({required this.animations});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFF395587);
    
    for (int i = 0; i < animations.length; i++) {
      final progress = animations[i];
      final offsetX = size.width * 0.5 + 
          math.cos(progress * 2 * math.pi + i * 1.5) * size.width * 0.3;
      final offsetY = size.height * 0.5 + 
          math.sin(progress * 2 * math.pi + i * 2) * size.height * 0.3;
      
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.15 + i * 0.05),
            baseColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(offsetX, offsetY),
          radius: size.width * (0.3 + i * 0.1),
        ));
      
      canvas.drawCircle(
        Offset(offsetX, offsetY),
        size.width * (0.3 + i * 0.1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LavaLampPainter oldDelegate) => true;
}
