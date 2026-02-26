import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiSystem extends StatefulWidget {
  final Widget child;
  final bool shouldBlast;

  const ConfettiSystem({
    super.key,
    required this.child,
    required this.shouldBlast,
  });

  @override
  State<ConfettiSystem> createState() => _ConfettiSystemState();
}

class _ConfettiSystemState extends State<ConfettiSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.update(_controller.value);
        }
      });
    });
  }

  @override
  void didUpdateWidget(ConfettiSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldBlast && !oldWidget.shouldBlast) {
      _blast();
    }
  }

  void _blast() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(ConfettiParticle());
    }
    _controller.forward(from: 0);
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
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: ConfettiPainter(_particles),
            ),
          ),
      ],
    );
  }
}

class ConfettiParticle {
  late double x;
  late double y;
  late double speedX;
  late double speedY;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle() {
    final random = Random();
    x = 0.5; // Start from center (normalized 0-1)
    y = 0.5;
    double angle = random.nextDouble() * 2 * pi;
    double speed = 0.5 + random.nextDouble() * 0.5;
    speedX = cos(angle) * speed;
    speedY = sin(angle) * speed;
    color = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple
    ][random.nextInt(5)];
    size = 4 + random.nextDouble() * 6;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
  }

  void update(double t) {
    x += speedX * 0.02;
    y += speedY * 0.02 + 0.01; // Gravity
    rotation += rotationSpeed;
    // Decelerate
    speedX *= 0.95;
    speedY *= 0.95;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()..color = particle.color;
      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: particle.size, height: particle.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
