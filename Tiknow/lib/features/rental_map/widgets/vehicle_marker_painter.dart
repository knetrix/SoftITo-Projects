import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Araç simgeleri + kullanıcı konumu. Konumlar 0..1 normalize edilmiştir.
/// [scale] harita yakınlaştırmasıdır; simgeler ekranda sabit boyutta kalır.
class VehicleMarkerPainter extends CustomPainter {
  const VehicleMarkerPainter({
    required this.points,
    required this.semanticLabels,
    required this.selectedIndex,
    required this.userPoint,
    required this.scale,
    required this.markerColor,
    required this.selectedColor,
    required this.iconColor,
    required this.ringColor,
    required this.userColor,
    this.onMarkerTap,
  });

  static const double markerRadius = 16;
  static const double hitRadius = 24;

  final List<Offset> points;
  final List<String> semanticLabels;
  final int? selectedIndex;
  final Offset userPoint;
  final double scale;
  final Color markerColor;
  final Color selectedColor;
  final Color iconColor;
  final Color ringColor;
  final Color userColor;
  final ValueChanged<int>? onMarkerTap;

  @override
  void paint(Canvas canvas, Size size) {
    final inv = 1 / scale;
    _drawUser(canvas, size, inv);
    for (var i = 0; i < points.length; i++) {
      if (i == selectedIndex) continue;
      _drawMarker(canvas, size, i, inv, selected: false);
    }
    final selected = selectedIndex;
    if (selected != null && selected < points.length) {
      _drawMarker(canvas, size, selected, inv, selected: true);
    }
  }

  Offset _at(Offset normalized, Size size) =>
      Offset(normalized.dx * size.width, normalized.dy * size.height);

  void _drawUser(Canvas canvas, Size size, double inv) {
    final c = _at(userPoint, size);
    canvas.drawCircle(c, 22 * inv, Paint()..color = userColor.withValues(alpha: 0.18));
    canvas.drawCircle(c, 9 * inv, Paint()..color = ringColor);
    canvas.drawCircle(c, 6.5 * inv, Paint()..color = userColor);
  }

  void _drawMarker(Canvas canvas, Size size, int index, double inv,
      {required bool selected}) {
    final c = _at(points[index], size);
    final r = (selected ? markerRadius * 1.25 : markerRadius) * inv;
    final fill = selected ? selectedColor : markerColor;

    final pin = Path()
      ..moveTo(c.dx - r * 0.55, c.dy + r * 0.55)
      ..lineTo(c.dx, c.dy + r * 1.7)
      ..lineTo(c.dx + r * 0.55, c.dy + r * 0.55)
      ..close();
    canvas.drawPath(pin, Paint()..color = fill);
    canvas.drawCircle(c, r + 2.5 * inv, Paint()..color = ringColor);
    canvas.drawCircle(c, r, Paint()..color = fill);
    _drawCarGlyph(canvas, c, r);
  }

  void _drawCarGlyph(Canvas canvas, Offset center, double radius) {
    const icon = Icons.directions_car_filled;
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius * 1.35,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
    painter.dispose();
  }

  /// Dokunma noktasına en yakın araç indeksi (yarıçap [hitRadius] dp).
  static int? markerIndexAt(
    Offset position,
    Size size,
    List<Offset> points,
    double scale,
  ) {
    final limit = hitRadius / scale;
    int? best;
    var bestDistance = limit;
    for (var i = 0; i < points.length; i++) {
      final c = Offset(points[i].dx * size.width, points[i].dy * size.height);
      final d = (c - position).distance;
      if (d <= bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      final inv = 1 / scale;
      final half = hitRadius * inv;
      return [
        for (var i = 0; i < points.length && i < semanticLabels.length; i++)
          CustomPainterSemantics(
            key: ValueKey<int>(i),
            rect: Rect.fromCenter(
              center: _at(points[i], size),
              width: half * 2,
              height: half * 2,
            ),
            properties: SemanticsProperties(
              label: semanticLabels[i],
              textDirection: TextDirection.ltr,
              button: true,
              onTap: onMarkerTap == null ? null : () => onMarkerTap!(i),
            ),
          ),
      ];
    };
  }

  @override
  bool shouldRepaint(covariant VehicleMarkerPainter oldDelegate) {
    return !listEquals(oldDelegate.points, points) ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.userPoint != userPoint ||
        oldDelegate.scale != scale ||
        oldDelegate.markerColor != markerColor ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.iconColor != iconColor ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.userColor != userColor;
  }

  @override
  bool shouldRebuildSemantics(covariant VehicleMarkerPainter oldDelegate) {
    return !listEquals(oldDelegate.points, points) ||
        !listEquals(oldDelegate.semanticLabels, semanticLabels) ||
        oldDelegate.scale != scale;
  }
}
