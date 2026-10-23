import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark Palette (Gece Finans: Deep Navy & Emerald / Gold)
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF141E33);
  static const Color darkCard = Color(0xFF1A2642);
  static const Color darkPrimary = Color(0xFF10B981); // Emerald
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // High-contrast crisp white on emerald
  static const Color darkSecondary = Color(0xFFF59E0B); // Gold / Amber
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (clean readable white)
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400 (crystal clear readable silver)
  static const Color darkOutline = Color(0xFF2E3D5C);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF059669);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFD97706);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900 (deep readable charcoal)
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600 (strong high-contrast slate)
  static const Color lightOutline = Color(0xFFCBD5E1); // Slate 300 (clear visible border)

  // Common Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Kategori Renkleri
  static const Color categoryMarket = Color(0xFF10B981); // Emerald
  static const Color categoryTransport = Color(0xFF3B82F6); // Mavi
  static const Color categoryBills = Color(0xFFEF4444); // Kırmızı / Mercan
  static const Color categoryEntertainment = Color(0xFF8B5CF6); // Mor
  static const Color categoryHealth = Color(0xFFEC4899); // Pembe
  static const Color categoryEducation = Color(0xFFF59E0B); // Kehribar
  static const Color categoryOther = Color(0xFF64748B); // Gri / Slate
}
