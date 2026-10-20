import 'package:flutter/material.dart';

/// Uygulamanın tüm sabit renkleri. Widget içinde `Colors.xxx` kullanılmaz;
/// renkler buradan veya `Theme.of(context).colorScheme` üzerinden alınır.
abstract final class AppColors {
  static const Color primary = Color(0xFFFF7A1A);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF2B1400);

  static const Color primaryContainerLight = Color(0xFFFFE0C7);
  static const Color onPrimaryContainerLight = Color(0xFF3A1A00);
  static const Color primaryContainerDark = Color(0xFF5C2A00);
  static const Color onPrimaryContainerDark = Color(0xFFFFDCC2);

  static const Color success = Color(0xFF2E9E5B);
  static const Color transparent = Color(0x00000000);
  static const Color scrim = Color(0x66000000);

  /// Haritadaki kullanıcı konumu noktası.
  static const Color userLocation = Color(0xFF1A73E8);
}

/// İstanbul haritası için açık/koyu renk paleti (Google Maps görünümü).
@immutable
class MapPalette {
  const MapPalette({
    required this.water,
    required this.land,
    required this.park,
    required this.road,
    required this.roadCasing,
    required this.majorRoad,
    required this.majorRoadCasing,
    required this.label,
    required this.waterLabel,
  });

  final Color water;
  final Color land;
  final Color park;
  final Color road;
  final Color roadCasing;
  final Color majorRoad;
  final Color majorRoadCasing;
  final Color label;
  final Color waterLabel;

  static const MapPalette light = MapPalette(
    water: Color(0xFFAADAFF),
    land: Color(0xFFF2F0EA),
    park: Color(0xFFC9E7C4),
    road: Color(0xFFFFFFFF),
    roadCasing: Color(0xFFD9D6CE),
    majorRoad: Color(0xFFFCE29A),
    majorRoadCasing: Color(0xFFE5BC5A),
    label: Color(0xFF5F6368),
    waterLabel: Color(0xFF4A7BB5),
  );

  static const MapPalette dark = MapPalette(
    water: Color(0xFF17263C),
    land: Color(0xFF242F3E),
    park: Color(0xFF263C3F),
    road: Color(0xFF38414E),
    roadCasing: Color(0xFF1E2733),
    majorRoad: Color(0xFF7A6B4F),
    majorRoadCasing: Color(0xFF4A402E),
    label: Color(0xFF9CA3AF),
    waterLabel: Color(0xFF515C6D),
  );

  static MapPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
