import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/istanbul_geo.dart';

/// Haritadaki yazı (semt veya su adı).
@immutable
class MapLabel {
  const MapLabel({
    required this.text,
    required this.lat,
    required this.lon,
    this.isWater = false,
  });

  final String text;
  final double lat;
  final double lon;
  final bool isWater;

  @override
  bool operator ==(Object other) =>
      other is MapLabel &&
      other.text == text &&
      other.lat == lat &&
      other.lon == lon &&
      other.isWater == isWater;

  @override
  int get hashCode => Object.hash(text, lat, lon, isWater);
}

/// Google Maps görünümlü İstanbul haritası (harici harita paketi yok).
/// Yalnızca palet veya etiketler değişince yeniden çizilir.
class IstanbulMapPainter extends CustomPainter {
  const IstanbulMapPainter({required this.palette, required this.labels});

  final MapPalette palette;
  final List<MapLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 1000;
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.water);

    _drawLand(canvas, size, IstanbulGeo.europeLand);
    _drawLand(canvas, size, IstanbulGeo.asiaLand);
    _drawParks(canvas, size);
    _drawRoads(canvas, size, IstanbulGeo.minorRoads, unit * 5, unit * 3.4,
        palette.roadCasing, palette.road);
    _drawRoads(canvas, size, IstanbulGeo.majorRoads, unit * 9, unit * 6.4,
        palette.majorRoadCasing, palette.majorRoad);
    _drawLabels(canvas, size, unit);
  }

  Offset _toCanvas(GeoPoint p, Size size) {
    final n = IstanbulGeo.normalizePoint(p);
    return Offset(n.dx * size.width, n.dy * size.height);
  }

  void _drawLand(Canvas canvas, Size size, List<GeoPoint> polygon) {
    final path = Path()..addPolygon([for (final p in polygon) _toCanvas(p, size)], true);
    canvas.drawPath(path, Paint()..color = palette.land);
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.roadCasing
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width / 1000 * 1.5,
    );
  }

  void _drawParks(Canvas canvas, Size size) {
    final paint = Paint()..color = palette.park;
    for (final park in IstanbulGeo.parks) {
      final c = _toCanvas(park.center, size);
      final rx = park.radiusLon / (IstanbulGeo.lonMax - IstanbulGeo.lonMin);
      final ry = park.radiusLat / (IstanbulGeo.latMax - IstanbulGeo.latMin);
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: rx * 2 * size.width,
          height: ry * 2 * size.height,
        ),
        paint,
      );
    }
  }

  void _drawRoads(
    Canvas canvas,
    Size size,
    List<List<GeoPoint>> roads,
    double casingWidth,
    double fillWidth,
    Color casingColor,
    Color fillColor,
  ) {
    final paths = [
      for (final road in roads)
        Path()..addPolygon([for (final p in road) _toCanvas(p, size)], false),
    ];
    final casing = Paint()
      ..color = casingColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = casingWidth;
    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = fillWidth;
    for (final path in paths) {
      canvas.drawPath(path, casing);
    }
    for (final path in paths) {
      canvas.drawPath(path, fill);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double unit) {
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(
          text: label.text,
          style: TextStyle(
            color: label.isWater ? palette.waterLabel : palette.label,
            fontSize: unit * (label.isWater ? 15 : 13),
            fontWeight: label.isWater ? FontWeight.w500 : FontWeight.w600,
            fontStyle: label.isWater ? FontStyle.italic : FontStyle.normal,
            letterSpacing: label.isWater ? unit * 1.5 : 0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final at = _toCanvas((lon: label.lon, lat: label.lat), size);
      painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant IstanbulMapPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        !listEquals(oldDelegate.labels, labels);
  }
}
