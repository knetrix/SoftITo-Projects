import 'package:flutter/painting.dart';

/// Archivo değişken font ölçeği (7V7_HANDOFF.md §2.3).
/// `wght` ve `wdth` eksenleri her stilde birlikte verilir.
abstract final class AppTextStyles {
  static const String family = 'Archivo';

  static TextStyle s(
    double size,
    int weight, {
    double width = 100,
    double height = 1.4,
    Color? color,
    bool tabular = false,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      // M3 varsayılan metin temasının letterSpacing'i (0.1–0.5) devralınmasın.
      letterSpacing: 0,
      color: color,
      fontWeight: _weight(weight),
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation('wdth', width),
      ],
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
      decoration: decoration,
      decorationColor: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static FontWeight _weight(int w) {
    final i = ((w / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[i];
  }

  /// 34 / 900 / wdth 112 — yalnızca Karşılama başlığı.
  static TextStyle display({Color? color}) =>
      s(34, 900, width: 112, height: 1.08, color: color);

  /// 28 / 900 / wdth 118 — ekran başlıkları.
  static TextStyle title({Color? color}) =>
      s(28, 900, width: 118, height: 1.15, color: color);

  /// 20 / 900 / wdth 112 — panel başlığı, boş durum başlığı.
  static TextStyle titleSm({Color? color}) =>
      s(20, 900, width: 112, height: 1.2, color: color);

  static TextStyle body(int weight, {Color? color, double width = 100}) =>
      s(16, weight, width: width, color: color);

  static TextStyle bodySm(int weight, {Color? color, bool tabular = false}) =>
      s(14, weight, color: color, tabular: tabular);

  static TextStyle label(int weight, {Color? color, bool tabular = false}) =>
      s(12, weight, height: 1.3, color: color, tabular: tabular);

  /// Buton metni: 16 / 800 / wdth 108.
  static TextStyle button({Color? color, double size = 16}) =>
      s(size, 800, width: 108, color: color);
}
