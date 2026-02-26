import 'package:flutter/material.dart';
import 'dart:math';

class WeeklyTrendChart extends StatelessWidget {
  final List<int> weeklySteps;
  final List<String> labels;
  final Color barColor;

  const WeeklyTrendChart({
    super.key,
    required this.weeklySteps,
    required this.labels,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (weeklySteps.isNotEmpty)
                Text(
                  'Avg: ${(weeklySteps.reduce((a, b) => a + b) / weeklySteps.length).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _ChartPainter(
                data: weeklySteps,
                labels: labels,
                color: barColor,
                textColor:
                    Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final Color color;
  final Color textColor;

  _ChartPainter({
    required this.data,
    required this.labels,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxSteps = data.reduce(max);
    final maxVal = maxSteps > 0 ? maxSteps : 1;

    // Calculate width for each bar group (bar + gap)
    // We have N bars. N labels.
    // Total width = size.width.
    // gap = barWidth.
    // Total units = N * 2 - 1 (N bars + N-1 gaps)?
    // Or just N slots.

    final count = data.length;
    final slotWidth = size.width / count;
    final barWidth = slotWidth * 0.4;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < count; i++) {
      final value = i < data.length ? data[i] : 0;
      final height =
          (value / maxVal) * (size.height - 30); // Reserve 30 for labels

      final left = (i * slotWidth) + (slotWidth - barWidth) / 2;
      final top = size.height - 30 - height;
      final right = left + barWidth;
      final bottom = size.height - 30;

      // Draw Bar Background (optional for richness)
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, 0, right, bottom),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, Paint()..color = color.withOpacity(0.1));

      // Draw Bar
      final r = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(4),
      );
      canvas.drawRRect(r, paint);

      // Draw Label
      if (i < labels.length) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(color: textColor, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(left + (barWidth - textPainter.width) / 2, size.height - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.labels != labels ||
        oldDelegate.color != color;
  }
}
