// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Money Habit Tracker';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navChallenge => 'Challenge';

  @override
  String get navGoals => 'Hedeflerim';

  @override
  String get navExpenses => 'Harcamalar';

  @override
  String get navBudget => 'Bütçe';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get emailLabel => 'E-Posta';

  @override
  String get phoneLabel => 'Telefon Numarası';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get confirmPasswordLabel => 'Şifre Tekrar';

  @override
  String get registerButton => 'Hesap Oluştur';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabınız var mı?';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get loginHere => 'Giriş Yapın';

  @override
  String get registerHere => 'Kayıt Olun';

  @override
  String get quickLogin => 'Hızlı Giriş (Test Kullanıcısı)';

  @override
  String get quickLoginHint => 'Test kullanıcısı ile tek tıkla giriş yapın';

  @override
  String get loginFailed => 'E-posta veya şifre hatalı';

  @override
  String get userAlreadyExists =>
      'Bu e-posta adresiyle kayıtlı kullanıcı zaten var';

  @override
  String get errorRequired => 'Bu alan zorunludur';

  @override
  String get errorInvalidEmail => 'Geçerli bir e-posta adresi giriniz';

  @override
  String get errorInvalidPhone =>
      '5 ile başlayan 10 haneli telefon numarası giriniz';

  @override
  String get errorWeakPassword =>
      'En az 8 karakter, 1 büyük, 1 küçük harf ve 1 rakam içermelidir';

  @override
  String get errorPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get errorInvalidAmount => 'Geçerli bir tutar giriniz';

  @override
  String get errorIncorrectPassword => 'Mevcut şifre hatalı';

  @override
  String get dashboardWelcome => 'Hoş Geldiniz';

  @override
  String get dashboardRemainingBudget => 'Bu Ayki Kalan Bütçe';

  @override
  String get dashboardTodayChallenge => 'Bugünkü Challenge Görevi';

  @override
  String get dashboardStreak => 'Seri';

  @override
  String dashboardDaysStreak(Object count) {
    return '$count Gün Seri';
  }

  @override
  String get dashboardNearestGoal => 'En Yakın Hedef';

  @override
  String get dashboardRecentExpenses => 'Son Harcamalar';

  @override
  String get dashboardNoExpenses => 'Henüz harcama kaydı bulunmuyor';

  @override
  String get dashboardNoChallenge => 'Aktif bir challenge bulunmuyor';

  @override
  String get dashboardNoGoal => 'Henüz finansal hedef eklenmemiş';

  @override
  String get dashboardStartChallenge => 'Challenge Başlat';

  @override
  String get dashboardAddGoal => 'Hedef Ekle';

  @override
  String get dashboardViewAll => 'Tümünü Gör';

  @override
  String get challengeTitle => '10 Günlük Challenge';

  @override
  String get challengeStartPrompt =>
      '10 Günlük Finansal Farkındalık Challenge\'ına Başla!';

  @override
  String get challengeStartButton => 'Yeni Challenge Başlat';

  @override
  String get challengeRestartButton => 'Challenge\'ı Yeniden Başlat';

  @override
  String get challengeCompletedTitle => 'Tebrikler! 🎉';

  @override
  String get challengeCompletedMessage =>
      '10 günlük finansal challenge\'ı başarıyla tamamladınız! Harika bir alışkanlık edindiniz.';

  @override
  String challengeDay(Object day) {
    return 'Gün $day';
  }

  @override
  String challengeDaysCounter(Object current) {
    return '$current/10 Gün';
  }

  @override
  String challengeCurrentStreak(Object count) {
    return 'Güncel Seri: $count gün';
  }

  @override
  String challengeBestStreak(Object count) {
    return 'En İyi Seri: $count gün';
  }

  @override
  String get challengeTodayTask => 'Bugünün Görevi';

  @override
  String get challengeLocked => 'Kilitli (Sırası gelmedi)';

  @override
  String get challengeMissed => 'Kaçırıldı';

  @override
  String get challengeCompleteButton => 'Görevi Tamamla';

  @override
  String get challengeCompletedTask => 'Tamamlandı';

  @override
  String get goalsTitle => 'Finansal Hedeflerim';

  @override
  String get goalsEmpty =>
      'Henüz bir hedefiniz yok. Birikim yapmaya başlamak için yeni bir hedef oluşturun!';

  @override
  String get goalsAdd => 'Yeni Hedef Ekle';

  @override
  String get goalsNewTitle => 'Hedef Başlığı';

  @override
  String get goalsTargetAmount => 'Hedef Tutar';

  @override
  String get goalsSavedAmount => 'Biriken Tutar';

  @override
  String get goalsProgress => 'İlerleme';

  @override
  String get goalsAddStep => 'Para Ekle';

  @override
  String get goalsStepAmount => 'Eklenecek Tutar';

  @override
  String get goalsStepNote => 'Not (Opsiyonel)';

  @override
  String get goalsCompletedBadge => 'Tamamlandı 🎯';

  @override
  String get goalsDelete => 'Hedefi Sil';

  @override
  String get goalsDeleteConfirm =>
      'Bu hedefi ve tüm birikim adımlarını silmek istediğinize emin misiniz?';

  @override
  String get goalsStepsHistory => 'İlerleme Geçmişi';

  @override
  String get goalsNoSteps => 'Henüz birikim adımı eklenmedi.';

  @override
  String get expensesTitle => 'Harcama Kaydı';

  @override
  String get expensesEmpty => 'Bu dönemde harcama kaydı bulunmuyor.';

  @override
  String get expensesAdd => 'Harcama Ekle';

  @override
  String get expensesNewTitle => 'Yeni Harcama';

  @override
  String get expensesAmount => 'Tutar';

  @override
  String get expensesCategory => 'Kategori';

  @override
  String get expensesDate => 'Tarih';

  @override
  String get expensesNote => 'Açıklama (Opsiyonel)';

  @override
  String get expensesDelete => 'Harcamayı Sil';

  @override
  String get expensesDeletedMessage => 'Harcama silindi';

  @override
  String get expensesUndo => 'Geri Al';

  @override
  String get expensesMonthFilter => 'Ay Seçimi';

  @override
  String get categoryMarket => 'Market & Gıda';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryBills => 'Faturalar';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get budgetTitle => 'Bütçe & İstatistik';

  @override
  String get budgetMonthlyLimit => 'Aylık Bütçe Limiti';

  @override
  String get budgetSetLimit => 'Limit Belirle';

  @override
  String get budgetSpent => 'Harcanan';

  @override
  String get budgetRemaining => 'Kalan';

  @override
  String get budgetOverBudget => 'Bütçe Aşıldı!';

  @override
  String get budgetCategoryDistribution => 'Kategori Dağılımı';

  @override
  String get budgetWeeklyExpenses => 'Son 7 Gün Harcamaları';

  @override
  String get budgetLimitInput => 'Yeni Bütçe Limiti';

  @override
  String get budgetNoCategoryData => 'Grafik için harcama verisi bulunmuyor';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsTheme => 'Görünüm & Tema';

  @override
  String get settingsThemeDark => 'Koyu Tema (Varsayılan)';

  @override
  String get settingsThemeLight => 'Aydınlık Tema';

  @override
  String get settingsLanguage => 'Uygulama Dili';

  @override
  String get settingsLangTr => 'Türkçe';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsAccountUpdate => 'Hesap Bilgilerini Güncelle';

  @override
  String get settingsUpdateSuccess => 'Bilgileriniz başarıyla güncellendi';

  @override
  String get settingsLogout => 'Çıkış Yap';

  @override
  String get settingsLogoutConfirm => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get settingsPickAvatar => 'Profil Resmi Seç';

  @override
  String get settingsAvatarPreset => 'Hazır Avatarlar';

  @override
  String get settingsAvatarGallery => 'Galeriden Seç';

  @override
  String get settingsAvatarCamera => 'Kameradan Çek';

  @override
  String settingsRegisteredAt(Object date) {
    return 'Kayıt Tarihi: $date';
  }

  @override
  String get settingsCurrentPassword => 'Mevcut Şifre';

  @override
  String get settingsNewPassword => 'Yeni Şifre';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get commonToday => 'Bugün';

  @override
  String get commonYesterday => 'Dün';
}
