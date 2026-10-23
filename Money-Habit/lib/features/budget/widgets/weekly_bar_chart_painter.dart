import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class WeeklyBarChartPainter extends CustomPainter {
  final Map<DateTime, int> dailyExpenses;
  final Color barColor;
  final Color trackColor;
  final Color textColor;
  final String localeCode;

  WeeklyBarChartPainter({
    required this.dailyExpenses,
    required this.barColor,
    required this.trackColor,
    required this.textColor,
    required this.localeCode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyExpenses.isEmpty) return;

    final count = dailyExpenses.length;
    final totalWidth = size.width;
    final chartHeight = size.height - 24;
    final barWidth = (totalWidth / count) * 0.45;
    final slotWidth = totalWidth / count;

    int maxAmount = 1;
    for (final amount in dailyExpenses.values) {
      if (amount > maxAmount) maxAmount = amount;
    }

    int index = 0;
    for (final entry in dailyExpenses.entries) {
      final date = entry.key;
      final amount = entry.value;

      final centerX = (index * slotWidth) + (slotWidth / 2);
      final left = centerX - (barWidth / 2);
      final right = centerX + (barWidth / 2);

      // Background track
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, 0, right, chartHeight),
        const Radius.circular(6),
      );
      final trackPaint = Paint()..color = trackColor;
      canvas.drawRRect(trackRect, trackPaint);

      // Active bar
      final ratio = (amount / maxAmount).clamp(0.0, 1.0);
      final barHeight = math.max(ratio * chartHeight, amount > 0 ? 6.0 : 0.0);
      final barTop = chartHeight - barHeight;

      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(left, barTop, right, chartHeight),
          const Radius.circular(6),
        );
        final barPaint = Paint()..color = barColor;
        canvas.drawRRect(barRect, barPaint);
      }

      // Date label
      final dayFormat = intl.DateFormat.E(localeCode);
      final labelText = dayFormat.format(date).substring(0, 1).toUpperCase();

      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), chartHeight + 6),
      );

      index++;
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.dailyExpenses != dailyExpenses ||
        oldDelegate.barColor != barColor ||
        oldDelegate.trackColor != trackColor;
  }
}
