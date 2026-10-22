import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/habits/models/habit_model.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/community/models/tournament_model.dart';
import '../../features/statistics/models/ai_insight_model.dart';
import '../utils/date_utils.dart';

class StorageService {
  static StorageService? _instance;
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = StorageService._(prefs);
    }
    return _instance!;
  }

  // ================= HABITS =================
  Future<void> saveHabits(List<HabitModel> habits) async {
    final jsonList = habits.map((h) => h.toJson()).toList();
    await _prefs.setString(AppConstants.keyHabits, jsonEncode(jsonList));
  }

  List<HabitModel> loadHabits() {
    final raw = _prefs.getString(AppConstants.keyHabits);
    if (raw == null || raw.isEmpty) {
      return _seedDefaultHabits();
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => HabitModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return _seedDefaultHabits();
    }
  }

  List<HabitModel> _seedDefaultHabits() {
    final today = AppDateUtils.todayString();
    final yesterday = AppDateUtils.yesterdayString();
    return [
      HabitModel(
        id: 'habit-1',
        title: '2.5 Litre Su İç',
        description: 'Vücudunu zinde ve enerjik tut.',
        frequency: 'Her Gün',
        reminderTime: '09:00',
        streakCount: 7,
        bestStreak: 14,
        isCompletedToday: true,
        completedDates: [yesterday, today],
        category: 'Sağlık & Spor',
      ),
      HabitModel(
        id: 'habit-2',
        title: '20 Sayfa Kitap Oku',
        description: 'Her gün düzenli okuma alışkanlığı.',
        frequency: 'Her Gün',
        reminderTime: '21:30',
        streakCount: 4,
        bestStreak: 10,
        isCompletedToday: false,
        completedDates: [yesterday],
        category: 'Zihin & Odak',
      ),
      HabitModel(
        id: 'habit-3',
        title: 'Flutter & Dart Kodlama',
        description: 'En az 45 dakika yeni mimari ve projeler çalış.',
        frequency: 'Her Gün',
        reminderTime: '14:00',
        streakCount: 12,
        bestStreak: 12,
        isCompletedToday: true,
        completedDates: [yesterday, today],
        category: 'Öğrenme & Kod',
      ),
      HabitModel(
        id: 'habit-4',
        title: '10 Dakika Meditasyon & Nefes',
        description: 'Güne zihinsel berraklıkla başla.',
        frequency: 'Hafta İçi',
        reminderTime: '07:30',
        streakCount: 2,
        bestStreak: 5,
        isCompletedToday: false,
        completedDates: [],
        category: 'Kişisel Gelişim',
      ),
    ];
  }

  // ================= USER =================
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  UserModel? loadUser() {
    final raw = _prefs.getString(AppConstants.keyUser);
    if (raw == null || raw.isEmpty) {
      return _seedDefaultUser();
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return _seedDefaultUser();
    }
  }

  UserModel _seedDefaultUser() {
    return const UserModel(
      id: 'user-001',
      name: 'Melih Rutino',
      email: 'melih@rutino.com',
      phone: '+90 555 123 4567',
      avatarUrl: 'assets/avatars/avatar1.png',
      totalPoints: 680,
      preferredLanguage: 'tr',
      isDarkMode: true,
    );
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.keyUser);
  }

  // ================= THEME & LANGUAGE =================
  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.keyDarkMode, isDark);
  }

  bool loadDarkMode() {
    return _prefs.getBool(AppConstants.keyDarkMode) ?? true;
  }

  Future<void> saveLanguage(String lang) async {
    await _prefs.setString(AppConstants.keyLanguage, lang);
  }

  String loadLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'tr';
  }

  // ================= TOURNAMENTS =================
  Future<void> saveTournaments(List<TournamentModel> tournaments) async {
    final jsonList = tournaments.map((t) => t.toJson()).toList();
    await _prefs.setString(AppConstants.keyTournaments, jsonEncode(jsonList));
  }

  List<TournamentModel> loadTournaments() {
    final raw = _prefs.getString(AppConstants.keyTournaments);
    if (raw == null || raw.isEmpty) {
      return _seedDefaultTournaments();
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TournamentModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return _seedDefaultTournaments();
    }
  }

  List<TournamentModel> _seedDefaultTournaments() {
    return const [
      TournamentModel(
        id: 'tour-1',
        title: '30 Gün Kesintisiz Kodlama Turnuvası',
        description: 'Her gün en az 30 dk kod yazarak seriyi bozmayan geliştiriciler yarışıyor!',
        habitId: 'habit-3',
        participantCount: 428,
        startDate: '2026-10-01',
        endDate: '2026-10-31',
        rewardPoints: 1000,
        isJoined: true,
        leaderboard: [
          {'rank': 1, 'name': 'Ahmet Y.', 'streak': 22, 'points': 890},
          {'rank': 2, 'name': 'Melih Rutino', 'streak': 21, 'points': 850},
          {'rank': 3, 'name': 'Selin D.', 'streak': 20, 'points': 820},
          {'rank': 4, 'name': 'Barış K.', 'streak': 19, 'points': 760},
          {'rank': 5, 'name': 'Ece V.', 'streak': 18, 'points': 720},
        ],
      ),
      TournamentModel(
        id: 'tour-2',
        title: 'Haftalık 20 Litre Su Challenge',
        description: 'Günlük hidrasyon hedefini tamamla, haftalık 500 bonus puanı kap!',
        habitId: 'habit-1',
        participantCount: 1120,
        startDate: '2026-10-18',
        endDate: '2026-10-25',
        rewardPoints: 500,
        isJoined: false,
        leaderboard: [
          {'rank': 1, 'name': 'Gamze T.', 'streak': 7, 'points': 350},
          {'rank': 2, 'name': 'Burak A.', 'streak': 7, 'points': 350},
          {'rank': 3, 'name': 'Deniz M.', 'streak': 6, 'points': 300},
        ],
      ),
      TournamentModel(
        id: 'tour-3',
        title: 'Sabah Erken Uyanma & Meditasyon',
        description: 'Sabah 07:00 öncesi zihnini toparla, güne önde başla.',
        habitId: 'habit-4',
        participantCount: 310,
        startDate: '2026-10-15',
        endDate: '2026-11-15',
        rewardPoints: 750,
        isJoined: false,
        leaderboard: [
          {'rank': 1, 'name': 'Zeynep K.', 'streak': 14, 'points': 560},
          {'rank': 2, 'name': 'Emre B.', 'streak': 13, 'points': 520},
        ],
      ),
    ];
  }

  // ================= AI INSIGHTS =================
  Future<void> saveAiInsights(List<AIInsightModel> insights) async {
    final jsonList = insights.map((i) => i.toJson()).toList();
    await _prefs.setString(AppConstants.keyAiInsights, jsonEncode(jsonList));
  }

  List<AIInsightModel> loadAiInsights() {
    final raw = _prefs.getString(AppConstants.keyAiInsights);
    if (raw == null || raw.isEmpty) {
      return [
        const AIInsightModel(
          id: 'insight-seed',
          userId: 'user-001',
          generatedSummary:
              'Tebrikler Melih! Bu hafta kodlama ve su içme alışkanlıklarında %85 başarı oranına ulaştın. Kitap okuma serini korumak için akşam saatlerinde 15 dakikalık mini seanslar belirlemen faydalı olacaktır.',
          suggestions: [
            'Akşam 21:00 için bir bildirim hatırlatıcısı ekle.',
            'Su hedefini 3 litreye çıkararak ekstra streak bonusu kazan.',
            '30 Günlük Kodlama Turnuvası liderliği için sadece 40 puana ihtiyacın var!',
          ],
          createdAt: '2026-10-22',
        ),
        const AIInsightModel(
          id: 'insight-seed-en',
          userId: 'user-001',
          generatedSummary:
              'Congratulations Melih! This week you reached an 85% success rate in your coding and water habits. Short 15-minute evening sessions will help you keep your reading streak alive.',
          suggestions: [
            'Add a reminder for 21:00 in the evening.',
            'Raise your water goal to 3 liters to earn an extra streak bonus.',
            'You only need 40 points to lead the 30-Day Coding Tournament!',
          ],
          createdAt: '2026-10-22',
          language: 'en',
        ),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => AIInsightModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
