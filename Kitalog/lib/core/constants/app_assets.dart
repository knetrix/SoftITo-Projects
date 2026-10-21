abstract final class AppAssets {
  static const String splashLogo = 'assets/icon/splash_logo.png';

  /// Hazır avatar anahtarları (`assets/avatars/<anahtar>.png`).
  static const List<String> presetAvatarKeys = [
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_5',
    'avatar_6',
  ];

  static String avatarPath(String key) => 'assets/avatars/$key.png';
}
