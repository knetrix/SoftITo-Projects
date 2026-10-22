/// Rutino genel uygulama sabitleri
abstract class AppConstants {
  static const String appVersion = '1.0.0';
  static const int pointPerCompletion = 15;
  static const int streakBonusMultiplier = 5;

  // Varsayılan Kategoriler
  static const List<String> categories = [
    'Sağlık & Spor',
    'Zihin & Odak',
    'Öğrenme & Kod',
    'Kişisel Gelişim',
    'Üretkenlik',
  ];

  // Sıklık Seçenekleri
  static const List<String> frequencies = [
    'Her Gün',
    'Hafta İçi',
    'Hafta Sonu',
    'Haftada 3 Gün',
  ];

  // Depolama Anahtarları (Storage Keys)
  static const String keyHabits = 'rutino_habits_v1';
  static const String keyUser = 'rutino_user_v1';
  static const String keyDarkMode = 'rutino_dark_mode_v1';
  static const String keyLanguage = 'rutino_language_v1';
  static const String keyTournaments = 'rutino_tournaments_v1';
  static const String keyAiInsights = 'rutino_ai_insights_v1';
}
