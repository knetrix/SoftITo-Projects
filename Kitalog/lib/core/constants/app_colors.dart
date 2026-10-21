import 'package:flutter/material.dart';

/// Tüm renkler burada tanımlıdır: "Gece Kütüphanesi" (koyu), "Kağıt" (aydınlık)
/// paletleri ve tür renkleri. Widget içinde `Color(0x...)` kullanılmaz.
abstract final class AppColors {
  // Gece Kütüphanesi (koyu)
  static const Color inkBlack = Color(0xFF14161B);
  static const Color inkSurface = Color(0xFF1D2027);
  static const Color inkSurfaceHigh = Color(0xFF272B34);
  static const Color inkOutline = Color(0xFF3A3F4A);
  static const Color amber = Color(0xFFF2A93B);
  static const Color amberContainer = Color(0xFF4A3410);
  static const Color inkText = Color(0xFFECE7DC);
  static const Color inkTextMuted = Color(0xFFA9A396);

  // Kağıt (aydınlık)
  static const Color paper = Color(0xFFF6F0E4);
  static const Color paperSurface = Color(0xFFFFFBF2);
  static const Color paperSurfaceHigh = Color(0xFFEDE5D3);
  static const Color paperOutline = Color(0xFFD3C8B0);
  static const Color amberDeep = Color(0xFF9A5F0B);
  static const Color amberLight = Color(0xFFFFE3B0);
  static const Color paperText = Color(0xFF2A2620);
  static const Color paperTextMuted = Color(0xFF6B6354);

  // Durum renkleri
  static const Color errorDark = Color(0xFFEF7B70);
  static const Color errorLight = Color(0xFFB3261E);
  static const Color success = Color(0xFF6FBF73);
  static const Color successDeep = Color(0xFF2E7D32);
  static const Color star = Color(0xFFF2B53B);

  // Tür renkleri
  static const Color genreNovel = Color(0xFFD9695F);
  static const Color genreScience = Color(0xFF4FA3D1);
  static const Color genreHistory = Color(0xFFC49A5A);
  static const Color genrePhilosophy = Color(0xFF8E7CC3);
  static const Color genrePersonalDevelopment = Color(0xFF5FB3A1);
  static const Color genreSciFiFantasy = Color(0xFF6C8BE0);
  static const Color genreBiography = Color(0xFFE08A4F);
  static const Color genrePoetry = Color(0xFFD97AA6);
  static const Color genreChildren = Color(0xFF8FBF5A);
  static const Color genreOther = Color(0xFF8C93A0);

  /// Tür renklerinin üzerindeki yazı rengi.
  static const Color onGenre = Color(0xFF14161B);

  static const Color scrim = Color(0xB3000000);
  static const Color transparent = Color(0x00000000);
}
