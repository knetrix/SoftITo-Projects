import 'package:flutter/material.dart';

/// Süre / km kullanım çubuğu (harici paketsiz). [ratio] 0..1'e kırpılır.
class RentalUsageBarPainter extends CustomPainter {
  const RentalUsageBarPainter({
    required this.ratio,
    required this.fillColor,
    required this.trackColor,
  });

  final double ratio;
  final Color fillColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );

    final fillWidth = size.width * ratio.clamp(0.0, 1.0);
    if (fillWidth <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        radius,
      ),
      Paint()..color = fillColor,
    );
  }

  @override
  bool shouldRepaint(covariant RentalUsageBarPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor;
  }
}
