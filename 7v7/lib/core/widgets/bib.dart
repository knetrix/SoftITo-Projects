import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Yelek durumları (§2.7).
enum BibKind {
  /// Kaleci (dolu): `bibGk` dolgu, `#13201A` numara.
  gk,

  /// Saha oyuncusu, sahada (dolu): `bib` dolgu, `#0F5132` numara.
  onPitch,

  /// Saha dışında (kadro listesi, profil): `team` dolgu, beyaz numara.
  team,

  /// Boş mevki / davet bekleyen mevki (sahada): yarı saydam, beyaz kesikli kontur.
  empty,

  /// Sana teklif edilen mevki: beyaz dolgu, `#13201A` 2 px kesikli kontur.
  offer,

  /// Boş (saha dışı liste): dolgusuz, `ink2` kesikli kontur.
  line,
}

/// SVG yolu `M8 2h8c1 4 3 6 6 6s5-2 6-6h8v8c0 3 2 5 4 6v30H4V16c2-1 4-3 4-6z`
/// (viewBox 0 0 44 48), mutlak koordinatlara çevrilmiş hali.
Path bibPath() => Path()
  ..moveTo(8, 2)
  ..lineTo(16, 2)
  ..cubicTo(17, 6, 19, 8, 22, 8)
  ..cubicTo(25, 8, 27, 6, 28, 2)
  ..lineTo(36, 2)
  ..lineTo(36, 10)
  ..cubicTo(36, 13, 38, 15, 40, 16)
  ..lineTo(40, 46)
  ..lineTo(4, 46)
  ..lineTo(4, 16)
  ..cubicTo(6, 15, 8, 13, 8, 10)
  ..close();

/// Yelek bileşeni — `CustomPainter` ile çizilir; numara x=22, y=35, 16/900.
class Bib extends StatelessWidget {
  const Bib({
    super.key,
    required this.kind,
    this.number,
    this.width = 40,
    this.height = 44,
    this.fill,
  });

  final BibKind kind;
  final String? number;
  final double width;
  final double height;

  /// Özel dolgu (ör. avatar yeleği). Verilirse `kind` rengini ezer.
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: BibPainter(
          kind: kind,
          number: number,
          colors: c,
          fill: fill,
        ),
      ),
    );
  }
}

class BibPainter extends CustomPainter {
  BibPainter({
    required this.kind,
    required this.colors,
    this.number,
    this.fill,
  });

  final BibKind kind;
  final AppColors colors;
  final String? number;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 44×48, "meet" ölçekleme (ortalanmış).
    final s = (size.width / 44) < (size.height / 48)
        ? size.width / 44
        : size.height / 48;
    final dx = (size.width - 44 * s) / 2;
    final dy = (size.height - 48 * s) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s);
    final path = bibPath();

    Color? fillColor;
    Color? strokeColor;
    double strokeWidth = 0;
    Color textColor;
    switch (kind) {
      case BibKind.gk:
        fillColor = AppColors.bibGk;
        textColor = AppColors.kitInk;
      case BibKind.onPitch:
        fillColor = colors.bib;
        textColor = AppColors.kitGreen;
      case BibKind.team:
        fillColor = colors.team;
        textColor = AppColors.white;
      case BibKind.empty:
        fillColor = AppColors.bibEmptyFill;
        strokeColor = AppColors.white;
        strokeWidth = 1.5;
        textColor = AppColors.white;
      case BibKind.offer:
        fillColor = AppColors.white;
        strokeColor = AppColors.kitInk;
        strokeWidth = 2;
        textColor = AppColors.kitGreen;
      case BibKind.line:
        strokeColor = colors.ink2;
        strokeWidth = 1.5;
        textColor = colors.ink2;
    }
    if (fill != null) fillColor = fill;

    if (fillColor != null) {
      canvas.drawPath(path, Paint()..color = fillColor);
    }
    if (strokeColor != null) {
      canvas.drawPath(
        dashPath(path, 4, 3),
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
    if (number != null && number!.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: number,
          style: AppTextStyles.s(16, 900, height: 1, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final baseline =
          tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      tp.paint(canvas, Offset(22 - tp.width / 2, 35 - baseline));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BibPainter old) =>
      old.kind != kind ||
      old.number != number ||
      old.colors != colors ||
      old.fill != fill;
}

/// Kesikli çizgi (stroke-dasharray `dash gap`).
Path dashPath(Path source, double dash, double gap) {
  final out = Path();
  for (final ui.PathMetric m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      final len = (d + dash).clamp(0, m.length).toDouble();
      out.addPath(m.extractPath(d, len), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

/// Kullanıcı avatarı (§2.7): 44×48 yelek + ortada baş harf yaması.
/// Kaleci avatarı `bibGk`, diğerleri `avatarTeam`.
class BibAvatar extends StatelessWidget {
  const BibAvatar({
    super.key,
    required this.initials,
    this.goalkeeper = false,
    this.scale = 1,
  });

  final String initials;
  final bool goalkeeper;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = goalkeeper ? AppColors.bibGk : AppColors.avatarTeam;
    final avatar = SizedBox(
      width: 44,
      height: 48,
      child: Stack(
        children: [
          Bib(kind: BibKind.team, width: 44, height: 48, fill: color),
          Positioned(
            left: 8,
            right: 8,
            top: 19,
            child: Container(
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                initials,
                maxLines: 1,
                style: AppTextStyles.s(14, 800,
                    height: 20 / 14,
                    color: goalkeeper ? AppColors.kitInk : AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
    return ExcludeSemantics(
      child: scale == 1 ? avatar : Transform.scale(scale: scale, child: avatar),
    );
  }
}

/// Profil avatarı (§2.7): 56×61 `team` yelek, yama 16/900.
class ProfileBibAvatar extends StatelessWidget {
  const ProfileBibAvatar({super.key, required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ExcludeSemantics(
      child: SizedBox(
        width: 56,
        height: 61,
        child: Stack(
          children: [
            const Bib(kind: BibKind.team, width: 56, height: 61),
            Positioned(
              left: 12,
              right: 12,
              top: 24,
              child: Container(
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.team,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  initials,
                  maxLines: 1,
                  style: AppTextStyles.s(16, 900,
                      height: 24 / 16, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
