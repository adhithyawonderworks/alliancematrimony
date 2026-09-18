import 'dart:math';
import 'package:flutter/material.dart';

class _Dot {
  double x, y, size, opacity, speedX, speedY;
  _Dot({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });
}

class AuthBackgroundWidget extends StatefulWidget {
  const AuthBackgroundWidget({super.key});

  @override
  State<AuthBackgroundWidget> createState() => _AuthBackgroundWidgetState();
}

class _AuthBackgroundWidgetState extends State<AuthBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Dot> _dots;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _dots = List.generate(
      30,
      (_) => _Dot(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        opacity: _random.nextDouble() * 0.4 + 0.1,
        speedX: (_random.nextDouble() - 0.5) * 0.0003,
        speedY: (_random.nextDouble() - 0.5) * 0.0003,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _controller.addListener(() {
      setState(() {
        for (final dot in _dots) {
          dot.x += dot.speedX;
          dot.y += dot.speedY;
          if (dot.x < 0 || dot.x > 1) dot.speedX = -dot.speedX;
          if (dot.y < 0 || dot.y > 1) dot.speedY = -dot.speedY;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF2A1020), Color(0xFF120D16)],
              ),
            ),
          ),
          ..._dots.map(
            (dot) => Positioned(
              left: dot.x * size.width,
              top: dot.y * size.height,
              child: Container(
                width: dot.size,
                height: dot.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC8556A).withValues(alpha: dot.opacity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
