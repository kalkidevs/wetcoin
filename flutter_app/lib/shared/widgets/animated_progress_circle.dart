import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

class AnimatedProgressCircle extends StatefulWidget {
  final int steps;
  final int goal;
  final double size;

  const AnimatedProgressCircle({
    super.key,
    required this.steps,
    required this.goal,
    this.size = 280,
  });

  @override
  State<AnimatedProgressCircle> createState() => _AnimatedProgressCircleState();
}

class _AnimatedProgressCircleState extends State<AnimatedProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignSystem.durationVerySlow,
    );

    final progress = (widget.steps / widget.goal).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.curveEaseOut),
    );
    _previousProgress = progress;

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps || oldWidget.goal != widget.goal) {
      final newProgress = (widget.steps / widget.goal).clamp(0.0, 1.0);
      _animation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: DesignSystem.curveEaseOut),
      );
      _previousProgress = newProgress;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle (Subtle)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 20,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Animated Gradient Progress
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GradientProgressPainter(
                  progress: _animation.value,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9966),
                      Color(0xFF00C853)
                    ], // Saffron to Green
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: 20,
                ),
              );
            },
          ),
          // Inner Content (Steps Counter)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 32,
              ),
              const SizedBox(height: DesignSystem.s8),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.steps),
                duration: DesignSystem.durationVerySlow,
                curve: DesignSystem.curveEaseOut,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.displayMedium?.color ??
                          Theme.of(context).textTheme.bodyLarge?.color,
                      letterSpacing: -1.0,
                    ),
                  );
                },
              ),
              const SizedBox(height: DesignSystem.s4),
              Text(
                'steps today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: (Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey)
                      .withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double width;

  _GradientProgressPainter({
    required this.progress,
    required this.gradient,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - width) / 2;

    // Paint for the arc
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Apply gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = gradient.createShader(rect);

    // Draw arc (start from top -90 degrees)
    // 2 * pi is full circle
    canvas.drawArc(
      rect,
      -pi / 2, // Start at top
      2 * pi * progress,
      false,
      paint,
    );

    // Add Glow at the tip
    if (progress > 0) {
      final angle = -pi / 2 + (2 * pi * progress);
      final tipX = center.dx + radius * cos(angle);
      final tipY = center.dy + radius * sin(angle);

      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(tipX, tipY), width / 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradient != gradient ||
        oldDelegate.width != width;
  }
}
