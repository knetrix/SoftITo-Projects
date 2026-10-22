/// Rutino yerelleştirme sözlüğü ve dinamik dil motoru
/// Türkçe (varsayılan) ve İngilizce desteği
abstract class AppStrings {
  static String _currentLanguage = 'tr';

  static void setLanguage(String lang) {
    if (lang == 'en' || lang == 'tr') {
      _currentLanguage = lang;
    }
  }

  static String get currentLanguage => _currentLanguage;
  static bool get isEnglish => _currentLanguage == 'en';

  // ================= GENEL =================
  static String get appName => 'Rutino';
  static String get appTagline =>
      isEnglish ? 'Manage Habits, Keep Your Streak!' : 'Alışkanlıklarını Yönet, Serini Koru!';
  static String get save => isEnglish ? 'Save' : 'Kaydet';
  static String get cancel => isEnglish ? 'Cancel' : 'İptal';
  static String get delete => isEnglish ? 'Delete' : 'Sil';
  static String get edit => isEnglish ? 'Edit' : 'Düzenle';
  static String get daysUnit => isEnglish ? 'Days' : 'Gün';
  static String get dayUnit => isEnglish ? 'Day' : 'Gün';

  // ================= SEKME BAŞLIKLARI =================
  static String get tabHabits => isEnglish ? 'Habits' : 'Alışkanlıklar';
  static String get tabStats => isEnglish ? 'Statistics' : 'İstatistikler';
  static String get tabCommunity => isEnglish ? 'Community' : 'Topluluk';
  static String get tabProfile => isEnglish ? 'Profile' : 'Profil';

  // ================= GİRİŞ / KAYIT =================
  static String get loginTitle => isEnglish ? 'Welcome Back' : 'Tekrar Hoş Geldin';
  static String get loginSubtitle =>
      isEnglish ? 'Continue your routine where you left off.' : 'Rutinine kaldığın yerden devam et.';
  static String get registerTitle => isEnglish ? 'Join Rutino' : 'Rutino\'ya Katıl';
  static String get registerSubtitle =>
      isEnglish ? 'New goals, unbroken streaks.' : 'Yeni hedefler, kesintisiz seriler.';
  static String get emailLabel => isEnglish ? 'Email Address' : 'E-posta Adresi';
  static String get emailHint => isEnglish ? 'example@rutino.com' : 'ornek@rutino.com';
  static String get phoneLabel => isEnglish ? 'Phone Number' : 'Telefon Numarası';
  static String get phoneHint => isEnglish ? '+1 5XX XXX XX XX' : '+90 5XX XXX XX XX';
  static String get passwordLabel => isEnglish ? 'Password' : 'Şifre';
  static String get nameLabel => isEnglish ? 'Full Name' : 'Ad Soyad';
  static String get loginButton => isEnglish ? 'Log In' : 'Giriş Yap';
  static String get registerButton => isEnglish ? 'Sign Up' : 'Kayıt Ol';
  static String get guestButton => isEnglish ? 'Continue as Guest' : 'Misafir Olarak Devam Et';
  static String get alreadyHaveAccount =>
      isEnglish ? 'Already have an account? Log In' : 'Zaten hesabın var mı? Giriş Yap';
  static String get doNotHaveAccount =>
      isEnglish ? 'Don\'t have an account? Sign Up' : 'Hesabın yok mu? Kayıt Ol';

  // ================= ALIŞKANLIKLAR =================
  static String get habitsTitle => isEnglish ? 'Today\'s Routines' : 'Bugünün Rutinleri';
  static String get filterAll => isEnglish ? 'All' : 'Tümü';
  static String get filterToday => isEnglish ? 'Today' : 'Bugün';
  static String get filterCompleted => isEnglish ? 'Completed' : 'Tamamlanan';
  static String get addHabit => isEnglish ? 'Add New Habit' : 'Yeni Alışkanlık Ekle';
  static String get editHabit => isEnglish ? 'Edit Habit' : 'Alışkanlığı Düzenle';
  static String get habitTitleLabel => isEnglish ? 'Habit Title' : 'Alışkanlık Başlığı';
  static String get habitTitleHint =>
      isEnglish ? 'e.g., Read Books, Drink Water, Run' : 'Örn: Kitap Oku, Su İç, Koşu Yap';
  static String get habitDescLabel => isEnglish ? 'Description (Optional)' : 'Açıklama (İsteğe bağlı)';
  static String get habitDescHint =>
      isEnglish ? 'Write a note to motivate yourself...' : 'Kendini motive edecek bir not yaz...';
  static String get habitCategoryLabel => isEnglish ? 'Category' : 'Kategori';
  static String get habitFrequencyLabel => isEnglish ? 'Frequency' : 'Sıklık';
  static String get habitTimeLabel => isEnglish ? 'Reminder Time' : 'Hatırlatıcı Saati';
  static String get timeNotSelected => isEnglish ? 'No Time Selected' : 'Saat Seçilmedi';
  static String get habitEmptyState => isEnglish
      ? 'You haven\'t added any habits yet.\nStart your streak by adding your first habit!'
      : 'Henüz hiç alışkanlık eklemedin.\nİlk alışkanlığını ekleyerek seriye başla!';
  static String get streakDays => isEnglish ? 'Day Streak' : 'Günlük Seri';
  static String get saveChanges => isEnglish ? 'Save Changes' : 'Değişiklikleri Kaydet';
  static String get createHabit => isEnglish ? 'Create Habit' : 'Alışkanlığı Oluştur';
  static String get deleteHabitConfirm => isEnglish ? 'Delete Habit' : 'Alışkanlığı Sil';
  static String deleteHabitMessage(String title) => isEnglish
      ? 'Are you sure you want to delete "$title"?'
      : '"$title" alışkanlığını silmek istediğinden emin misin?';
  static String get targetLabel => isEnglish ? 'Target' : 'Hedef';
  static String get successRateLabel => isEnglish ? 'Success' : 'Başarı';
  static String get pointsLabel => isEnglish ? 'Points' : 'Puan';

  // ================= İSTATİSTİKLER & AI =================
  static String get statsTitle => isEnglish ? 'Growth & Statistics' : 'Gelişim & İstatistik';
  static String get weeklyOverview =>
      isEnglish ? 'Weekly Completion Rate' : 'Haftalık Tamamlama Oranı';
  static String get last7Days => isEnglish ? 'Last 7 Days' : 'Son 7 Gün';
  static String get highestStreak => isEnglish ? 'Highest Streak' : 'En Yüksek Seri';
  static String get totalCheckmarks => isEnglish ? 'Total Checks' : 'Toplam Tik';
  static String get streakBadges =>
      isEnglish ? 'Streak Badges & Milestones' : 'Seri Rozetleri & Kademeler';
  static String get totalPoints => isEnglish ? 'Total Points' : 'Toplam Puan';
  static String get currentRank => isEnglish ? 'Current Level' : 'Mevcut Seviye';
  static String get aiCardTitle => isEnglish ? 'Rutino AI Coach' : 'Rutino Yapay Zeka Koçu';
  static String get aiCardSubtitle =>
      isEnglish ? 'Analyze your habits, get personal advice.' : 'Alışkanlıklarını analiz et, özel tavsiyeler al.';
  static String get aiAnalyzeButton =>
      isEnglish ? 'Analyze with AI' : 'Yapay Zeka ile Analiz Et';
  static String get aiAnalyzing => isEnglish ? 'Analyzing routines...' : 'Rutinlerin analiz ediliyor...';
  static String get aiDefaultPrompt => isEnglish
      ? 'Click the button below to analyze your habits and receive personalized recommendations.'
      : 'Alışkanlıklarınızı analiz etmek ve kişiselleştirilmiş motivasyon önerileri almak için aşağıdaki butona tıklayın.';

  // ================= TOPLULUK =================
  static String get communityTitle =>
      isEnglish ? 'Community & Tournaments' : 'Topluluk & Turnuvalar';
  static String get activeTournaments =>
      isEnglish ? 'Active Tournaments' : 'Aktif Turnuvalar';
  static String get communityFeed => isEnglish ? 'Community Feed' : 'Topluluk Başarı Akışı';
  static String get joinTournament => isEnglish ? 'Join' : 'Katıl';
  static String get joined => isEnglish ? 'Joined ✓' : 'Katıldın ✓';
  static String get leaderboard => isEnglish ? 'Leaderboard' : 'Sıralama';
  static String get tournamentLeaderboard =>
      isEnglish ? 'Tournament Leaderboard' : 'Turnuva Liderlik Tablosu';
  static String get participants => isEnglish ? 'Participants' : 'Katılımcı';
  static String get noTournaments =>
      isEnglish ? 'No active tournaments found.' : 'Aktif turnuva bulunmuyor.';
  static String get noLeaderboardData =>
      isEnglish ? 'No leaderboard data yet.' : 'Henüz liderlik verisi bulunmuyor.';

  // ================= PROFİL =================
  static String get profileTitle => isEnglish ? 'Profile & Settings' : 'Profil & Ayarlar';
  static String get editProfile => isEnglish ? 'Edit Profile' : 'Profili Düzenle';
  static String get themeMode => isEnglish ? 'Dark Theme (Obsidian)' : 'Koyu Tema (Obsidian)';
  static String get themeDarkSubtitle => isEnglish ? 'Dark (Obsidian)' : 'Karanlık (Obsidian)';
  static String get themeLightSubtitle => isEnglish ? 'Light' : 'Aydınlık';
  static String get language => isEnglish ? 'App Language' : 'Uygulama Dili';
  static String get trLanguage => 'Türkçe';
  static String get enLanguage => 'English';
  static String get currentRankTile =>
      isEnglish ? 'Current Rank & Level' : 'Mevcut Rutbe & Seviye';
  static String get appVersionTile => isEnglish ? 'App Version' : 'Uygulama Sürümü';
  static String get userNotFound =>
      isEnglish ? 'User session not found.' : 'Kullanıcı oturumu bulunamadı.';
  static String get logout => isEnglish ? 'Log Out' : 'Çıkış Yap';

  // ================= GÜNLER =================
  static List<String> get dayLabels => isEnglish
      ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      : const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
}
