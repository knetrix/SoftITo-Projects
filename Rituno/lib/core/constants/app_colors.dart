import 'package:flutter/material.dart';

/// Rutino renk paleti sabitleri ve dinamik tema yardımcıları
/// Koyu Tema (Obsidian & Canlı Vurgular) ve Aydınlık Tema (Yüksek Kontrast & Okunabilirlik)
abstract class AppColors {
  // Dark Obsidian Paleti (Varsayılan Koyu Tema)
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF181C26);
  static const Color darkCard = Color(0xFF222736);
  static const Color darkCardBorder = Color(0xFF2D3346);

  // Aydınlık Tema Paleti (Açık ve Yüksek Kontrastlı)
  static const Color lightBackground = Color(0xFFF1F5F9); // Slate-100 yumuşak zemin
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Slate-200 belirgin sınır

  // Canlı Vurgular & Aksanlar
  static const Color primary = Color(0xFF4F46E5); // Canlı İndigo
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);

  static const Color secondary = Color(0xFF0891B2); // Cyan-600 dengeli kontrast
  static const Color accent = Color(0xFF059669); // Emerald-600
  static const Color streakFire = Color(0xFFEA580C); // Canlı Turuncu
  static const Color streakFireGlow = Color(0xFFF97316);
  static const Color pointsGold = Color(0xFFD97706); // Amber-600 (Açık ve koyu zeminlerde net)

  // Durum Renkleri
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Metin Renkleri (Koyu Tema)
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Metin Renkleri (Aydınlık Tema - Yüksek Okunabilirlik)
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate-900 derin ve keskin
  static const Color lightTextSecondary = Color(0xFF334155); // Slate-700 rahat okunur
  static const Color lightTextMuted = Color(0xFF64748B); // Slate-500

  // ================= TEMA DUYARLI YARDIMCI METOTLAR =================
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color cardColor(BuildContext context) {
    return isDark(context) ? darkCard : lightCard;
  }

  static Color cardBorder(BuildContext context) {
    return isDark(context) ? darkCardBorder : lightCardBorder;
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? darkSurface : lightSurface;
  }

  static Color chipUnselectedBg(BuildContext context) {
    return isDark(context) ? darkSurface : const Color(0xFFE2E8F0);
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? darkTextPrimary : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? darkTextSecondary : lightTextSecondary;
  }

  static Color textMuted(BuildContext context) {
    return isDark(context) ? darkTextMuted : lightTextMuted;
  }

  static Color subCardBg(BuildContext context) {
    return isDark(context) ? darkSurface : const Color(0xFFF8FAFC);
  }
}
