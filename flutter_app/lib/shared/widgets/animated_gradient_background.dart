import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // _color1 and _color2 tweens are removed as we use Theme in build
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color1Begin = theme.scaffoldBackgroundColor;
    final color1End =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEFF3FF);

    final color2Begin = theme.cardColor;
    final color2End =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F0F0);

    return ListenableBuilder(
      listenable: _controller,
      child: widget.child,
      builder: (context, child) {
        final c1 = Color.lerp(color1Begin, color1End, _controller.value);
        final c2 = Color.lerp(color2Begin, color2End, _controller.value);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c1!, c2!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
