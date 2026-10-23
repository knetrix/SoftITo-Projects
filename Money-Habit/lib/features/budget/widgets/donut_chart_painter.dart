import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../expenses/models/expense_model.dart';

class DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, int> categoryAmounts;
  final Color emptyColor;

  DonutChartPainter({
    required this.categoryAmounts,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 20.0;

    final total = categoryAmounts.values.fold<int>(0, (sum, val) => sum + val);

    if (total == 0) {
      final paint = Paint()
        ..color = emptyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;

    for (final entry in categoryAmounts.entries) {
      if (entry.value <= 0) continue;
      final sweepAngle = (entry.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.categoryAmounts != categoryAmounts ||
        oldDelegate.emptyColor != emptyColor;
  }
}
