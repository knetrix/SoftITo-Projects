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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @readerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okuyucu'**
  String get readerTitle;

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Kitalog'**
  String get appName;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get commonAdd;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// No description provided for @commonUndo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get commonUndo;

  /// No description provided for @errorRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan boş bırakılamaz.'**
  String get errorRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Telefon 0 ile başlamalı, 11 haneli olmalı ve 0 (5XX) XXX XX XX biçiminde girilmelidir.'**
  String get errorPhoneInvalid;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordUppercase.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az bir büyük harf içermeli.'**
  String get errorPasswordUppercase;

  /// No description provided for @errorPasswordLowercase.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az bir küçük harf içermeli.'**
  String get errorPasswordLowercase;

  /// No description provided for @errorPasswordDigit.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az bir rakam içermeli.'**
  String get errorPasswordDigit;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get errorPasswordMismatch;

  /// No description provided for @genreNovel.
  ///
  /// In tr, this message translates to:
  /// **'Roman'**
  String get genreNovel;

  /// No description provided for @genreScience.
  ///
  /// In tr, this message translates to:
  /// **'Bilim'**
  String get genreScience;

  /// No description provided for @genreHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get genreHistory;

  /// No description provided for @genrePhilosophy.
  ///
  /// In tr, this message translates to:
  /// **'Felsefe'**
  String get genrePhilosophy;

  /// No description provided for @genrePersonalDevelopment.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Gelişim'**
  String get genrePersonalDevelopment;

  /// No description provided for @genreSciFiFantasy.
  ///
  /// In tr, this message translates to:
  /// **'Bilim Kurgu & Fantastik'**
  String get genreSciFiFantasy;

  /// No description provided for @genreBiography.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get genreBiography;

  /// No description provided for @genrePoetry.
  ///
  /// In tr, this message translates to:
  /// **'Şiir'**
  String get genrePoetry;

  /// No description provided for @genreChildren.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk'**
  String get genreChildren;

  /// No description provided for @genreOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get genreOther;

  /// No description provided for @statusToRead.
  ///
  /// In tr, this message translates to:
  /// **'Okunacak'**
  String get statusToRead;

  /// No description provided for @statusReading.
  ///
  /// In tr, this message translates to:
  /// **'Okunuyor'**
  String get statusReading;

  /// No description provided for @statusFinished.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get statusFinished;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık'**
  String get themeLight;

  /// No description provided for @pageProgress.
  ///
  /// In tr, this message translates to:
  /// **'{current} / {total} sayfa'**
  String pageProgress(int current, int total);

  /// No description provided for @progressPercent.
  ///
  /// In tr, this message translates to:
  /// **'%{percent}'**
  String progressPercent(int percent);

  /// No description provided for @progressSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Okuma ilerlemesi yüzde {percent}'**
  String progressSemantics(int percent);

  /// No description provided for @ratingStarSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{star} yıldız ver'**
  String ratingStarSemantics(int star);

  /// No description provided for @splashError.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi.'**
  String get splashError;

  /// No description provided for @authTagline.
  ///
  /// In tr, this message translates to:
  /// **'Sanal kütüphanen, cebinde.'**
  String get authTagline;

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

  /// No description provided for @fieldEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @hintPhone.
  ///
  /// In tr, this message translates to:
  /// **'0 (5XX) XXX XX XX'**
  String get hintPhone;

  /// No description provided for @fieldPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get fieldPasswordConfirm;

  /// No description provided for @showPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  /// No description provided for @buttonRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get buttonRegister;

  /// No description provided for @buttonLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get buttonLogin;

  /// No description provided for @linkHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş yap'**
  String get linkHaveAccount;

  /// No description provided for @linkNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get linkNoAccount;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorWrongCurrentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifre hatalı.'**
  String get errorWrongCurrentPassword;

  /// No description provided for @navLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığım'**
  String get navLibrary;

  /// No description provided for @navReadingStatus.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Durumu'**
  String get navReadingStatus;

  /// No description provided for @navGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get navGoal;

  /// No description provided for @libraryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığım'**
  String get libraryTitle;

  /// No description provided for @readingStatusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Durumu'**
  String get readingStatusTitle;

  /// No description provided for @readingGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Okuma Hedefi'**
  String get readingGoalTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @libraryFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get libraryFilterAll;

  /// No description provided for @librarySearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Başlık veya yazar ara'**
  String get librarySearchHint;

  /// No description provided for @libraryAddBook.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Ekle'**
  String get libraryAddBook;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığın henüz boş'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'İlk kitabını eklemek için “Kitap Ekle” düğmesine dokun.'**
  String get libraryEmptyMessage;

  /// No description provided for @libraryNoResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get libraryNoResultsTitle;

  /// No description provided for @libraryNoResultsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Arama veya filtreleri değiştirmeyi dene.'**
  String get libraryNoResultsMessage;

  /// No description provided for @loanedBadge.
  ///
  /// In tr, this message translates to:
  /// **'Ödünçte'**
  String get loanedBadge;

  /// No description provided for @bookDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Detayı'**
  String get bookDetailTitle;

  /// No description provided for @bookNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kitap bulunamadı.'**
  String get bookNotFound;

  /// No description provided for @authorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Yazar bilinmiyor'**
  String get authorUnknown;

  /// No description provided for @bookPageCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} sayfa'**
  String bookPageCount(int count);

  /// No description provided for @bookIsbn.
  ///
  /// In tr, this message translates to:
  /// **'ISBN: {isbn}'**
  String bookIsbn(String isbn);

  /// No description provided for @bookOwned.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığımda'**
  String get bookOwned;

  /// No description provided for @bookNotOwned.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığımda değil'**
  String get bookNotOwned;

  /// No description provided for @pageCounterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okuma İlerlemesi'**
  String get pageCounterTitle;

  /// No description provided for @pageEditTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa numarasını gir'**
  String get pageEditTooltip;

  /// No description provided for @pageEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut sayfa'**
  String get pageEditTitle;

  /// No description provided for @pageEditLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa (0 - {max})'**
  String pageEditLabel(int max);

  /// No description provided for @pageDecrement.
  ///
  /// In tr, this message translates to:
  /// **'1 sayfa geri'**
  String get pageDecrement;

  /// No description provided for @pageIncrement.
  ///
  /// In tr, this message translates to:
  /// **'1 sayfa ileri'**
  String get pageIncrement;

  /// No description provided for @pageDecrementBig.
  ///
  /// In tr, this message translates to:
  /// **'{count} sayfa geri'**
  String pageDecrementBig(int count);

  /// No description provided for @pageIncrementBig.
  ///
  /// In tr, this message translates to:
  /// **'{count} sayfa ileri'**
  String pageIncrementBig(int count);

  /// No description provided for @finishSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Son sayfaya ulaştın. Kitabı bitirdin mi?'**
  String get finishSuggestion;

  /// No description provided for @markFinished.
  ///
  /// In tr, this message translates to:
  /// **'Bitti olarak işaretle'**
  String get markFinished;

  /// No description provided for @statusSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Durumu'**
  String get statusSectionTitle;

  /// No description provided for @startedAtLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç: {date}'**
  String startedAtLabel(String date);

  /// No description provided for @finishedAtLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş: {date}'**
  String finishedAtLabel(String date);

  /// No description provided for @ratingSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Puan ve İnceleme'**
  String get ratingSectionTitle;

  /// No description provided for @reviewEdit.
  ///
  /// In tr, this message translates to:
  /// **'İncelemeyi düzenle'**
  String get reviewEdit;

  /// No description provided for @reviewDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şahsi İnceleme'**
  String get reviewDialogTitle;

  /// No description provided for @reviewHint.
  ///
  /// In tr, this message translates to:
  /// **'İncelemeni yaz'**
  String get reviewHint;

  /// No description provided for @reviewEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz inceleme yazmadın.'**
  String get reviewEmpty;

  /// No description provided for @quotesSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alıntılar'**
  String get quotesSectionTitle;

  /// No description provided for @quotesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz alıntı eklenmedi.'**
  String get quotesEmpty;

  /// No description provided for @quoteAdd.
  ///
  /// In tr, this message translates to:
  /// **'Alıntı Ekle'**
  String get quoteAdd;

  /// No description provided for @quoteText.
  ///
  /// In tr, this message translates to:
  /// **'Alıntı metni'**
  String get quoteText;

  /// No description provided for @quotePage.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa no (isteğe bağlı)'**
  String get quotePage;

  /// No description provided for @quotePageLabel.
  ///
  /// In tr, this message translates to:
  /// **'s. {page}'**
  String quotePageLabel(int page);

  /// No description provided for @quoteFavorite.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get quoteFavorite;

  /// No description provided for @quoteUnfavorite.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get quoteUnfavorite;

  /// No description provided for @quoteDelete.
  ///
  /// In tr, this message translates to:
  /// **'Alıntıyı sil'**
  String get quoteDelete;

  /// No description provided for @notesSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notesSectionTitle;

  /// No description provided for @notesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz not eklenmedi.'**
  String get notesEmpty;

  /// No description provided for @noteAdd.
  ///
  /// In tr, this message translates to:
  /// **'Not Ekle'**
  String get noteAdd;

  /// No description provided for @noteContent.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get noteContent;

  /// No description provided for @noteDelete.
  ///
  /// In tr, this message translates to:
  /// **'Notu sil'**
  String get noteDelete;

  /// No description provided for @loanSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç Bilgisi'**
  String get loanSectionTitle;

  /// No description provided for @loanNone.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitap ödünç verilmedi.'**
  String get loanNone;

  /// No description provided for @loanLend.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç Ver'**
  String get loanLend;

  /// No description provided for @loanBorrower.
  ///
  /// In tr, this message translates to:
  /// **'Kime ödünç verildi?'**
  String get loanBorrower;

  /// No description provided for @loanDueDate.
  ///
  /// In tr, this message translates to:
  /// **'İade tarihi seç (isteğe bağlı)'**
  String get loanDueDate;

  /// No description provided for @loanClearDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi temizle'**
  String get loanClearDate;

  /// No description provided for @loanLentTo.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine ödünç verildi'**
  String loanLentTo(String name);

  /// No description provided for @loanLentAt.
  ///
  /// In tr, this message translates to:
  /// **'Veriliş tarihi: {date}'**
  String loanLentAt(String date);

  /// No description provided for @loanDueAt.
  ///
  /// In tr, this message translates to:
  /// **'İade tarihi: {date}'**
  String loanDueAt(String date);

  /// No description provided for @loanOverdue.
  ///
  /// In tr, this message translates to:
  /// **'İade tarihi geçti'**
  String get loanOverdue;

  /// No description provided for @loanReturn.
  ///
  /// In tr, this message translates to:
  /// **'İade alındı'**
  String get loanReturn;

  /// No description provided for @deleteBook.
  ///
  /// In tr, this message translates to:
  /// **'Kitabı sil'**
  String get deleteBook;

  /// No description provided for @deleteBookTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap silinsin mi?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In tr, this message translates to:
  /// **'“{title}” ve ona ait alıntı ile notlar kalıcı olarak silinecek.'**
  String deleteBookMessage(String title);

  /// No description provided for @readingTabLabel.
  ///
  /// In tr, this message translates to:
  /// **'{status} ({count})'**
  String readingTabLabel(String status, int count);

  /// No description provided for @readingEmptyReadingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an okuduğun kitap yok'**
  String get readingEmptyReadingTitle;

  /// No description provided for @readingEmptyReadingMessage.
  ///
  /// In tr, this message translates to:
  /// **'Okunacak listenden bir kitap seçip okumaya başla.'**
  String get readingEmptyReadingMessage;

  /// No description provided for @readingEmptyToReadTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okunacak listen boş'**
  String get readingEmptyToReadTitle;

  /// No description provided for @readingEmptyToReadMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığından bir kitabı “Okunacak” olarak işaretle.'**
  String get readingEmptyToReadMessage;

  /// No description provided for @readingEmptyFinishedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bitirdiğin kitap yok'**
  String get readingEmptyFinishedTitle;

  /// No description provided for @readingEmptyFinishedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bitirdiğin kitaplar burada görünecek.'**
  String get readingEmptyFinishedMessage;

  /// No description provided for @startReading.
  ///
  /// In tr, this message translates to:
  /// **'Okumaya Başla'**
  String get startReading;

  /// No description provided for @errorPageCountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa sayısı 1 veya daha büyük bir sayı olmalı.'**
  String get errorPageCountInvalid;

  /// No description provided for @errorUrlInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir http/https adresi girin.'**
  String get errorUrlInvalid;

  /// No description provided for @errorIsbnInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir ISBN girin (10 veya 13 hane).'**
  String get errorIsbnInvalid;

  /// No description provided for @addBookTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kitap Ekle'**
  String get addBookTitle;

  /// No description provided for @addBookModeSearch.
  ///
  /// In tr, this message translates to:
  /// **'ISBN / Arama'**
  String get addBookModeSearch;

  /// No description provided for @addBookModeManual.
  ///
  /// In tr, this message translates to:
  /// **'Manuel'**
  String get addBookModeManual;

  /// No description provided for @addBookSearchLabel.
  ///
  /// In tr, this message translates to:
  /// **'ISBN, başlık veya yazar'**
  String get addBookSearchLabel;

  /// No description provided for @addBookSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 9780375508325 veya Cosmos'**
  String get addBookSearchHint;

  /// No description provided for @addBookSearchButton.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get addBookSearchButton;

  /// No description provided for @addBookSearchEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Open Library\'de kitap ara'**
  String get addBookSearchEmptyTitle;

  /// No description provided for @addBookSearchEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'ISBN numarası ya da başlık/yazar yazıp ara. Bulamazsan manuel ekleyebilirsin.'**
  String get addBookSearchEmptyMessage;

  /// No description provided for @addBookErrorEmptyQuery.
  ///
  /// In tr, this message translates to:
  /// **'Aramak için bir ISBN, başlık veya yazar yaz.'**
  String get addBookErrorEmptyQuery;

  /// No description provided for @addBookErrorInvalidIsbn.
  ///
  /// In tr, this message translates to:
  /// **'Bu ISBN geçerli değil. Rakamları kontrol et.'**
  String get addBookErrorInvalidIsbn;

  /// No description provided for @addBookErrorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı. Kitabı manuel ekleyebilirsin.'**
  String get addBookErrorNotFound;

  /// No description provided for @addBookErrorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı kurulamadı.'**
  String get addBookErrorNetwork;

  /// No description provided for @addBookErrorServer.
  ///
  /// In tr, this message translates to:
  /// **'Open Library şu an yanıt vermiyor.'**
  String get addBookErrorServer;

  /// No description provided for @addBookErrorDuplicate.
  ///
  /// In tr, this message translates to:
  /// **'Bu ISBN ile kayıtlı bir kitap zaten var.'**
  String get addBookErrorDuplicate;

  /// No description provided for @addBookGoManual.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Ekle'**
  String get addBookGoManual;

  /// No description provided for @addBookSave.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplığa Ekle'**
  String get addBookSave;

  /// No description provided for @addBookSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kitap kitaplığa eklendi.'**
  String get addBookSaved;

  /// No description provided for @fieldBookTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap adı'**
  String get fieldBookTitle;

  /// No description provided for @fieldBookAuthors.
  ///
  /// In tr, this message translates to:
  /// **'Yazar(lar)'**
  String get fieldBookAuthors;

  /// No description provided for @fieldBookAuthorsHelper.
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla yazarı virgülle ayır.'**
  String get fieldBookAuthorsHelper;

  /// No description provided for @fieldBookPages.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa sayısı'**
  String get fieldBookPages;

  /// No description provided for @fieldBookGenre.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get fieldBookGenre;

  /// No description provided for @fieldBookStatus.
  ///
  /// In tr, this message translates to:
  /// **'Okuma durumu'**
  String get fieldBookStatus;

  /// No description provided for @fieldBookIsbn.
  ///
  /// In tr, this message translates to:
  /// **'ISBN (isteğe bağlı)'**
  String get fieldBookIsbn;

  /// No description provided for @fieldBookCoverUrl.
  ///
  /// In tr, this message translates to:
  /// **'Kapak URL (isteğe bağlı)'**
  String get fieldBookCoverUrl;

  /// No description provided for @fieldBookOwned.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitap bende var'**
  String get fieldBookOwned;

  /// No description provided for @goalYearLabel.
  ///
  /// In tr, this message translates to:
  /// **'{year} Okuma Hedefi'**
  String goalYearLabel(int year);

  /// No description provided for @goalProgress.
  ///
  /// In tr, this message translates to:
  /// **'{finished} / {target} kitap'**
  String goalProgress(int finished, int target);

  /// No description provided for @goalRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe {count} kitap kaldı'**
  String goalRemaining(int count);

  /// No description provided for @goalCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık hedefine ulaştın, tebrikler!'**
  String get goalCompleted;

  /// No description provided for @goalTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {target} kitap'**
  String goalTarget(int target);

  /// No description provided for @goalDecrease.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi azalt'**
  String get goalDecrease;

  /// No description provided for @goalIncrease.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi artır'**
  String get goalIncrease;

  /// No description provided for @goalTotalPages.
  ///
  /// In tr, this message translates to:
  /// **'Toplam okunan sayfa'**
  String get goalTotalPages;

  /// No description provided for @goalMonthlyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık biten kitaplar'**
  String get goalMonthlyTitle;

  /// No description provided for @goalMonthSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{month}: {count} kitap'**
  String goalMonthSemantics(String month, int count);

  /// No description provided for @goalGenreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türlere göre dağılım'**
  String get goalGenreTitle;

  /// No description provided for @goalGenreEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu yıl henüz biten kitap yok.'**
  String get goalGenreEmpty;

  /// No description provided for @profileAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Profil resmi'**
  String get profileAvatar;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Profil resmini değiştir'**
  String get profileChangeAvatar;

  /// No description provided for @profileMemberSince.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik: {date}'**
  String profileMemberSince(String date);

  /// No description provided for @avatarPresetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazır avatar seç'**
  String get avatarPresetTitle;

  /// No description provided for @avatarFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden yükle'**
  String get avatarFromGallery;

  /// No description provided for @avatarFromCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayla çek'**
  String get avatarFromCamera;

  /// No description provided for @avatarRemove.
  ///
  /// In tr, this message translates to:
  /// **'Profil resmini kaldır'**
  String get avatarRemove;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsThemeTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguageTitle;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsUpdateEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini güncelle'**
  String get settingsUpdateEmail;

  /// No description provided for @settingsUpdatePhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarasını güncelle'**
  String get settingsUpdatePhone;

  /// No description provided for @settingsUpdatePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi güncelle'**
  String get settingsUpdatePassword;

  /// No description provided for @fieldCurrentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifre'**
  String get fieldCurrentPassword;

  /// No description provided for @fieldNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get fieldNewPassword;

  /// No description provided for @settingsEmailSaved.
  ///
  /// In tr, this message translates to:
  /// **'E-posta güncellendi.'**
  String get settingsEmailSaved;

  /// No description provided for @settingsPhoneSaved.
  ///
  /// In tr, this message translates to:
  /// **'Telefon güncellendi.'**
  String get settingsPhoneSaved;

  /// No description provided for @settingsPasswordSaved.
  ///
  /// In tr, this message translates to:
  /// **'Şifre güncellendi.'**
  String get settingsPasswordSaved;

  /// No description provided for @settingsAvatarSaved.
  ///
  /// In tr, this message translates to:
  /// **'Profil resmi güncellendi.'**
  String get settingsAvatarSaved;

  /// No description provided for @settingsAvatarFailed.
  ///
  /// In tr, this message translates to:
  /// **'Resim seçilemedi. Lütfen tekrar dene.'**
  String get settingsAvatarFailed;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılsın mı?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutMessage.
  ///
  /// In tr, this message translates to:
  /// **'Verilerin silinmez; tekrar giriş yapabilirsin.'**
  String get settingsLogoutMessage;

  /// No description provided for @readerDownloadTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitap henüz cihazında değil'**
  String get readerDownloadTitle;

  /// No description provided for @readerDownloadMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bir kez indir; sonra internet olmadan da okuyabilirsin.'**
  String get readerDownloadMessage;

  /// No description provided for @readerDownloadWebNote.
  ///
  /// In tr, this message translates to:
  /// **'Web sürümünde metin yalnızca bu oturum boyunca saklanır; çevrimdışı okuma için mobil uygulamayı kullan.'**
  String get readerDownloadWebNote;

  /// No description provided for @readerDownloadButton.
  ///
  /// In tr, this message translates to:
  /// **'İndir ve Oku'**
  String get readerDownloadButton;

  /// No description provided for @readerDownloading.
  ///
  /// In tr, this message translates to:
  /// **'İndiriliyor… %{percent}'**
  String readerDownloading(int percent);

  /// No description provided for @readerErrorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı kurulamadı. İndirmek için bağlantı gerekiyor.'**
  String get readerErrorNetwork;

  /// No description provided for @readerErrorServer.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak şu an yanıt vermiyor. Biraz sonra tekrar dene.'**
  String get readerErrorServer;

  /// No description provided for @readerErrorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitabın metni kaynağında bulunamadı.'**
  String get readerErrorNotFound;

  /// No description provided for @readerErrorStorage.
  ///
  /// In tr, this message translates to:
  /// **'Metin cihaza kaydedilemedi. Depolama alanını kontrol et.'**
  String get readerErrorStorage;

  /// No description provided for @readerErrorUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitabın ücretsiz dijital sürümü yok.'**
  String get readerErrorUnavailable;

  /// No description provided for @readerPageIndicator.
  ///
  /// In tr, this message translates to:
  /// **'{current} / {total}'**
  String readerPageIndicator(int current, int total);

  /// No description provided for @readerPrevious.
  ///
  /// In tr, this message translates to:
  /// **'Önceki sayfa'**
  String get readerPrevious;

  /// No description provided for @readerNext.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki sayfa'**
  String get readerNext;

  /// No description provided for @readerTextSize.
  ///
  /// In tr, this message translates to:
  /// **'Yazı boyutu'**
  String get readerTextSize;

  /// No description provided for @readerTextScaleValue.
  ///
  /// In tr, this message translates to:
  /// **'%{percent}'**
  String readerTextScaleValue(int percent);

  /// No description provided for @digitalSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dijital Sürüm'**
  String get digitalSectionTitle;

  /// No description provided for @digitalDownload.
  ///
  /// In tr, this message translates to:
  /// **'İndir (çevrimdışı okuma)'**
  String get digitalDownload;

  /// No description provided for @digitalRead.
  ///
  /// In tr, this message translates to:
  /// **'Oku'**
  String get digitalRead;

  /// No description provided for @digitalDelete.
  ///
  /// In tr, this message translates to:
  /// **'Cihazdan sil'**
  String get digitalDelete;

  /// No description provided for @fileErrorUnsupported.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca PDF ve EPUB dosyaları desteklenir.'**
  String get fileErrorUnsupported;

  /// No description provided for @fileErrorInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Dosya açılamadı; bozuk ya da geçersiz bir PDF/EPUB olabilir.'**
  String get fileErrorInvalid;

  /// No description provided for @fileErrorProtected.
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya kopya korumalı (DRM); korumalı kitaplar açılamaz.'**
  String get fileErrorProtected;

  /// No description provided for @fileErrorTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'Dosya çok büyük (en fazla 150 MB).'**
  String get fileErrorTooLarge;

  /// No description provided for @fileErrorMissing.
  ///
  /// In tr, this message translates to:
  /// **'Dosya bu cihazda bulunamadı. Kitap detayından yeniden yükleyebilirsin.'**
  String get fileErrorMissing;

  /// No description provided for @digitalImportHint.
  ///
  /// In tr, this message translates to:
  /// **'Kendi PDF veya EPUB dosyanı yükleyip uygulamada okuyabilirsin. Dosya yalnızca bu cihazda saklanır.'**
  String get digitalImportHint;

  /// No description provided for @digitalImportButton.
  ///
  /// In tr, this message translates to:
  /// **'Dosya yükle (PDF / EPUB)'**
  String get digitalImportButton;

  /// No description provided for @digitalImporting.
  ///
  /// In tr, this message translates to:
  /// **'Dosya hazırlanıyor…'**
  String get digitalImporting;

  /// No description provided for @digitalReplaceFile.
  ///
  /// In tr, this message translates to:
  /// **'Başka dosya yükle'**
  String get digitalReplaceFile;

  /// No description provided for @statusCurrentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Durum: {status}'**
  String statusCurrentLabel(String status);

  /// No description provided for @readAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Oku'**
  String get readAgain;

  /// No description provided for @finishConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitabı bitirdin mi?'**
  String get finishConfirmTitle;

  /// No description provided for @finishConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kitap \"Bitti\" olarak işaretlenecek ve okuma ilerlemesi son sayfaya getirilecek.'**
  String get finishConfirmMessage;

  /// No description provided for @readAgainConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitabı tekrar oku?'**
  String get readAgainConfirmTitle;

  /// No description provided for @readAgainConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Okuma ilerlemesi sıfırlanacak ve kitap \"Okunuyor\" durumuna geçecek. Yeniden bitirene kadar yıllık hedefte sayılmaz.'**
  String get readAgainConfirmMessage;
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
