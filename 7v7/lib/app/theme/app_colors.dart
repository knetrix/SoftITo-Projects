import 'package:flutter/material.dart';

/// Renk tokenları (7V7_HANDOFF.md §2.2). Widget'lar renkleri yalnızca buradan alır.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.accent,
    required this.onAccent,
    required this.line,
    required this.chip,
    required this.pitch,
    required this.bib,
    required this.team,
    required this.error,
    required this.ok,
    required this.mine,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color accent;
  final Color onAccent;
  final Color line;
  final Color chip;
  final Color pitch;
  final Color bib;
  final Color team;
  final Color error;
  final Color ok;
  final Color mine;

  // Temadan bağımsız sabitler (§2.2, §2.7, §2.8).
  static const Color bibGk = Color(0xFFFF6A13);
  static const Color avatarTeam = Color(0xFF1E6B3E);
  static const Color kitInk = Color(0xFF13201A);
  static const Color kitGreen = Color(0xFF0F5132);
  static const Color white = Color(0xFFFFFFFF);
  static const Color pitchLine = Color(0xB3FFFFFF); // rgba(255,255,255,.70)
  static const Color pitchMesh = Color(0x1FFFFFFF); // rgba(255,255,255,.12)
  static const Color bibEmptyFill = Color(0x24FFFFFF); // rgba(255,255,255,.14)
  static const Color slotLabelOff = Color(0x9906180E); // rgba(6,24,14,.6)
  static const Color segShadow = Color(0x24000000); // rgba(0,0,0,.14)
  static const Color toastBg = Color(0xFF111111); // prototip #toast
  static const Color scrim = Color(0x80000000); // alt panel arka planı

  static const AppColors light = AppColors(
    bg: Color(0xFFF6F7F3),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF13201A),
    ink2: Color(0xFF55605A),
    accent: Color(0xFF0F5132),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFFDDE2DC),
    chip: Color(0xFFECEFEA),
    pitch: Color(0xFF2E7D4F),
    bib: Color(0xFFFFFFFF),
    team: Color(0xFF0F5132),
    error: Color(0xFFB42318),
    ok: Color(0xFF1F6B3A),
    mine: Color(0xFFDCEFD9),
  );

  static const AppColors dark = AppColors(
    bg: Color(0xFF18201C),
    card: Color(0xFF212B26),
    ink: Color(0xFFF1F4F1),
    ink2: Color(0xFFAAB5AE),
    accent: Color(0xFF9BE29F),
    onAccent: Color(0xFF13201A),
    line: Color(0xFF36423C),
    chip: Color(0xFF2B3631),
    pitch: Color(0xFF1F5A39),
    bib: Color(0xFFF1F4F1),
    team: Color(0xFF2F7A4F),
    error: Color(0xFFFF8A80),
    ok: Color(0xFF8FD694),
    mine: Color(0xFF2D4A36),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      line: l(line, other.line),
      chip: l(chip, other.chip),
      pitch: l(pitch, other.pitch),
      bib: l(bib, other.bib),
      team: l(team, other.team),
      error: l(error, other.error),
      ok: l(ok, other.ok),
      mine: l(mine, other.mine),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get c => AppColors.of(this);
}
