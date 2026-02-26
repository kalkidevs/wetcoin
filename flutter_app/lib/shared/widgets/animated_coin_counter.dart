import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/design_system.dart';

class AnimatedCoinCounter extends StatelessWidget {
  final int amount;
  final bool compact;

  const AnimatedCoinCounter({
    super.key,
    required this.amount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: amount),
      duration: DesignSystem.durationSlow,
      curve: DesignSystem.curveEaseOut,
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/wetcoin.json',
              width: compact ? 30 : 40,
              height: compact ? 30 : 40,
            ),
            SizedBox(width: compact ? DesignSystem.s4 : DesignSystem.s8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: compact ? 18 : 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: -0.5,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: DesignSystem.s4),
              Text(
                'SWC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
