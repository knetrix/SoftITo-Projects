import 'dart:ui';

import 'package:flutter/rendering.dart';

import '../../app/theme/app_colors.dart';

/// Saha zemini + file dokusu + çizgiler (§2.8).
/// CSS kenarlıkları kutunun içine çizildiği için çizgi merkezleri 1 px içeridedir.
class PitchPainter extends CustomPainter {
  PitchPainter({required this.pitch, this.lines = true, this.mesh = true});

  final Color pitch;
  final bool lines;
  final bool mesh;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = pitch);

    if (mesh) {
      // 8 px ızgarada 1.2 px yarıçaplı beyaz noktalar, %12 opaklık.
      final pts = <Offset>[];
      for (double y = 4; y < h; y += 8) {
        for (double x = 4; x < w; x += 8) {
          pts.add(Offset(x, y));
        }
      }
      canvas.drawPoints(
        PointMode.points,
        pts,
        Paint()
          ..color = AppColors.pitchMesh
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
    if (!lines) return;

    final p = Paint()
      ..color = AppColors.pitchLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Kenar çerçevesi: 12 px içeride, köşe 14.
    canvas.drawRRect(
      RRect.fromLTRBR(13, 13, w - 13, h - 13, const Radius.circular(13)),
      p,
    );
    // Orta çizgi.
    canvas.drawLine(Offset(12, h / 2 + 1), Offset(w - 12, h / 2 + 1), p);
    // Orta daire Ø72.
    canvas.drawCircle(Offset(w / 2 - 1, h / 2 - 1), 35, p);
    // Üst ve alt ceza alanı: yanlardan %28 içeride, 48 yükseklik, iç köşeler 12.
    final l = w * .28 + 1, r = w * .72 - 1;
    final top = Path()
      ..moveTo(l, 12)
      ..lineTo(l, 59 - 11)
      ..arcToPoint(Offset(l + 11, 59), radius: const Radius.circular(11), clockwise: false)
      ..lineTo(r - 11, 59)
      ..arcToPoint(Offset(r, 59 - 11), radius: const Radius.circular(11), clockwise: false)
      ..lineTo(r, 12);
    canvas.drawPath(top, p);
    final by = h - 59;
    final bottom = Path()
      ..moveTo(l, h - 12)
      ..lineTo(l, by + 11)
      ..arcToPoint(Offset(l + 11, by), radius: const Radius.circular(11))
      ..lineTo(r - 11, by)
      ..arcToPoint(Offset(r, by + 11), radius: const Radius.circular(11))
      ..lineTo(r, h - 12);
    canvas.drawPath(bottom, p);
  }

  @override
  bool shouldRepaint(PitchPainter old) =>
      old.pitch != pitch || old.lines != lines || old.mesh != mesh;
}
