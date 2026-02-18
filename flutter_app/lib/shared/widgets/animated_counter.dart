import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const AnimatedCounter({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
      builder: (context, val, child) {
        return Text(
          val.toInt().toString(),
          style: style,
        );
      },
    );
  }
}
