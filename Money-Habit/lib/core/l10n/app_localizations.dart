import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Money Habit Tracker'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get navDashboard;

  /// No description provided for @navChallenge.
  ///
  /// In tr, this message translates to:
  /// **'Challenge'**
  String get navChallenge;

  /// No description provided for @navGoals.
  ///
  /// In tr, this message translates to:
  /// **'Hedeflerim'**
  String get navGoals;

  /// No description provided for @navExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get navExpenses;

  /// No description provided for @navBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get navBudget;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerTitle;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-Posta'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get phoneLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get confirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get registerButton;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabınız var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get dontHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapın'**
  String get loginHere;

  /// No description provided for @registerHere.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Olun'**
  String get registerHere;

  /// No description provided for @quickLogin.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Giriş (Test Kullanıcısı)'**
  String get quickLogin;

  /// No description provided for @quickLoginHint.
  ///
  /// In tr, this message translates to:
  /// **'Test kullanıcısı ile tek tıkla giriş yapın'**
  String get quickLoginHint;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get loginFailed;

  /// No description provided for @userAlreadyExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresiyle kayıtlı kullanıcı zaten var'**
  String get userAlreadyExists;

  /// No description provided for @errorRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunludur'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi giriniz'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In tr, this message translates to:
  /// **'5 ile başlayan 10 haneli telefon numarası giriniz'**
  String get errorInvalidPhone;

  /// No description provided for @errorWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter, 1 büyük, 1 küçük harf ve 1 rakam içermelidir'**
  String get errorWeakPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get errorPasswordMismatch;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar giriniz'**
  String get errorInvalidAmount;

  /// No description provided for @errorIncorrectPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifre hatalı'**
  String get errorIncorrectPassword;

  /// No description provided for @dashboardWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get dashboardWelcome;

  /// No description provided for @dashboardRemainingBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ayki Kalan Bütçe'**
  String get dashboardRemainingBudget;

  /// No description provided for @dashboardTodayChallenge.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Challenge Görevi'**
  String get dashboardTodayChallenge;

  /// No description provided for @dashboardStreak.
  ///
  /// In tr, this message translates to:
  /// **'Seri'**
  String get dashboardStreak;

  /// No description provided for @dashboardDaysStreak.
  ///
  /// In tr, this message translates to:
  /// **'{count} Gün Seri'**
  String dashboardDaysStreak(Object count);

  /// No description provided for @dashboardNearestGoal.
  ///
  /// In tr, this message translates to:
  /// **'En Yakın Hedef'**
  String get dashboardNearestGoal;

  /// No description provided for @dashboardRecentExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Son Harcamalar'**
  String get dashboardRecentExpenses;

  /// No description provided for @dashboardNoExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Henüz harcama kaydı bulunmuyor'**
  String get dashboardNoExpenses;

  /// No description provided for @dashboardNoChallenge.
  ///
  /// In tr, this message translates to:
  /// **'Aktif bir challenge bulunmuyor'**
  String get dashboardNoChallenge;

  /// No description provided for @dashboardNoGoal.
  ///
  /// In tr, this message translates to:
  /// **'Henüz finansal hedef eklenmemiş'**
  String get dashboardNoGoal;

  /// No description provided for @dashboardStartChallenge.
  ///
  /// In tr, this message translates to:
  /// **'Challenge Başlat'**
  String get dashboardStartChallenge;

  /// No description provided for @dashboardAddGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Ekle'**
  String get dashboardAddGoal;

  /// No description provided for @dashboardViewAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get dashboardViewAll;

  /// No description provided for @challengeTitle.
  ///
  /// In tr, this message translates to:
  /// **'10 Günlük Challenge'**
  String get challengeTitle;

  /// No description provided for @challengeStartPrompt.
  ///
  /// In tr, this message translates to:
  /// **'10 Günlük Finansal Farkındalık Challenge\'ına Başla!'**
  String get challengeStartPrompt;

  /// No description provided for @challengeStartButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Challenge Başlat'**
  String get challengeStartButton;

  /// No description provided for @challengeRestartButton.
  ///
  /// In tr, this message translates to:
  /// **'Challenge\'ı Yeniden Başlat'**
  String get challengeRestartButton;

  /// No description provided for @challengeCompletedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler! 🎉'**
  String get challengeCompletedTitle;

  /// No description provided for @challengeCompletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'10 günlük finansal challenge\'ı başarıyla tamamladınız! Harika bir alışkanlık edindiniz.'**
  String get challengeCompletedMessage;

  /// No description provided for @challengeDay.
  ///
  /// In tr, this message translates to:
  /// **'Gün {day}'**
  String challengeDay(Object day);

  /// No description provided for @challengeDaysCounter.
  ///
  /// In tr, this message translates to:
  /// **'{current}/10 Gün'**
  String challengeDaysCounter(Object current);

  /// No description provided for @challengeCurrentStreak.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Seri: {count} gün'**
  String challengeCurrentStreak(Object count);

  /// No description provided for @challengeBestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Seri: {count} gün'**
  String challengeBestStreak(Object count);

  /// No description provided for @challengeTodayTask.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Görevi'**
  String get challengeTodayTask;

  /// No description provided for @challengeLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli (Sırası gelmedi)'**
  String get challengeLocked;

  /// No description provided for @challengeMissed.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırıldı'**
  String get challengeMissed;

  /// No description provided for @challengeCompleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Tamamla'**
  String get challengeCompleteButton;

  /// No description provided for @challengeCompletedTask.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get challengeCompletedTask;

  /// No description provided for @goalsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Hedeflerim'**
  String get goalsTitle;

  /// No description provided for @goalsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir hedefiniz yok. Birikim yapmaya başlamak için yeni bir hedef oluşturun!'**
  String get goalsEmpty;

  /// No description provided for @goalsAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hedef Ekle'**
  String get goalsAdd;

  /// No description provided for @goalsNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Başlığı'**
  String get goalsNewTitle;

  /// No description provided for @goalsTargetAmount.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tutar'**
  String get goalsTargetAmount;

  /// No description provided for @goalsSavedAmount.
  ///
  /// In tr, this message translates to:
  /// **'Biriken Tutar'**
  String get goalsSavedAmount;

  /// No description provided for @goalsProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get goalsProgress;

  /// No description provided for @goalsAddStep.
  ///
  /// In tr, this message translates to:
  /// **'Para Ekle'**
  String get goalsAddStep;

  /// No description provided for @goalsStepAmount.
  ///
  /// In tr, this message translates to:
  /// **'Eklenecek Tutar'**
  String get goalsStepAmount;

  /// No description provided for @goalsStepNote.
  ///
  /// In tr, this message translates to:
  /// **'Not (Opsiyonel)'**
  String get goalsStepNote;

  /// No description provided for @goalsCompletedBadge.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı 🎯'**
  String get goalsCompletedBadge;

  /// No description provided for @goalsDelete.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi Sil'**
  String get goalsDelete;

  /// No description provided for @goalsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu hedefi ve tüm birikim adımlarını silmek istediğinize emin misiniz?'**
  String get goalsDeleteConfirm;

  /// No description provided for @goalsStepsHistory.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme Geçmişi'**
  String get goalsStepsHistory;

  /// No description provided for @goalsNoSteps.
  ///
  /// In tr, this message translates to:
  /// **'Henüz birikim adımı eklenmedi.'**
  String get goalsNoSteps;

  /// No description provided for @expensesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Kaydı'**
  String get expensesTitle;

  /// No description provided for @expensesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemde harcama kaydı bulunmuyor.'**
  String get expensesEmpty;

  /// No description provided for @expensesAdd.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Ekle'**
  String get expensesAdd;

  /// No description provided for @expensesNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Harcama'**
  String get expensesNewTitle;

  /// No description provided for @expensesAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get expensesAmount;

  /// No description provided for @expensesCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get expensesCategory;

  /// No description provided for @expensesDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get expensesDate;

  /// No description provided for @expensesNote.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (Opsiyonel)'**
  String get expensesNote;

  /// No description provided for @expensesDelete.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı Sil'**
  String get expensesDelete;

  /// No description provided for @expensesDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Harcama silindi'**
  String get expensesDeletedMessage;

  /// No description provided for @expensesUndo.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get expensesUndo;

  /// No description provided for @expensesMonthFilter.
  ///
  /// In tr, this message translates to:
  /// **'Ay Seçimi'**
  String get expensesMonthFilter;

  /// No description provided for @categoryMarket.
  ///
  /// In tr, this message translates to:
  /// **'Market & Gıda'**
  String get categoryMarket;

  /// No description provided for @categoryTransport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get categoryTransport;

  /// No description provided for @categoryBills.
  ///
  /// In tr, this message translates to:
  /// **'Faturalar'**
  String get categoryBills;

  /// No description provided for @categoryEntertainment.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get categoryEducation;

  /// No description provided for @categoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get categoryOther;

  /// No description provided for @budgetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe & İstatistik'**
  String get budgetTitle;

  /// No description provided for @budgetMonthlyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Bütçe Limiti'**
  String get budgetMonthlyLimit;

  /// No description provided for @budgetSetLimit.
  ///
  /// In tr, this message translates to:
  /// **'Limit Belirle'**
  String get budgetSetLimit;

  /// No description provided for @budgetSpent.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get budgetRemaining;

  /// No description provided for @budgetOverBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Aşıldı!'**
  String get budgetOverBudget;

  /// No description provided for @budgetCategoryDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Dağılımı'**
  String get budgetCategoryDistribution;

  /// No description provided for @budgetWeeklyExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Gün Harcamaları'**
  String get budgetWeeklyExpenses;

  /// No description provided for @budgetLimitInput.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bütçe Limiti'**
  String get budgetLimitInput;

  /// No description provided for @budgetNoCategoryData.
  ///
  /// In tr, this message translates to:
  /// **'Grafik için harcama verisi bulunmuyor'**
  String get budgetNoCategoryData;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm & Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema (Varsayılan)'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık Tema'**
  String get settingsThemeLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get settingsLanguage;

  /// No description provided for @settingsLangTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLangTr;

  /// No description provided for @settingsLangEn.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsAccountUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Bilgilerini Güncelle'**
  String get settingsAccountUpdate;

  /// No description provided for @settingsUpdateSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileriniz başarıyla güncellendi'**
  String get settingsUpdateSuccess;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinize emin misiniz?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsPickAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Profil Resmi Seç'**
  String get settingsPickAvatar;

  /// No description provided for @settingsAvatarPreset.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Avatarlar'**
  String get settingsAvatarPreset;

  /// No description provided for @settingsAvatarGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get settingsAvatarGallery;

  /// No description provided for @settingsAvatarCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Çek'**
  String get settingsAvatarCamera;

  /// No description provided for @settingsRegisteredAt.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Tarihi: {date}'**
  String settingsRegisteredAt(Object date);

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Şifre'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get settingsNewPassword;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get commonConfirm;

  /// No description provided for @commonToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get commonYesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
