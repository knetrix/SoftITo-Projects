// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get readerTitle => 'Okuyucu';

  @override
  String get appName => 'Kitalog';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonOk => 'Tamam';

  @override
  String get commonUndo => 'Geri al';

  @override
  String get errorRequired => 'Bu alan boş bırakılamaz.';

  @override
  String get errorEmailInvalid => 'Geçerli bir e-posta adresi girin.';

  @override
  String get errorPhoneInvalid =>
      'Telefon 0 ile başlamalı, 11 haneli olmalı ve 0 (5XX) XXX XX XX biçiminde girilmelidir.';

  @override
  String get errorPasswordTooShort => 'Şifre en az 8 karakter olmalı.';

  @override
  String get errorPasswordUppercase => 'Şifre en az bir büyük harf içermeli.';

  @override
  String get errorPasswordLowercase => 'Şifre en az bir küçük harf içermeli.';

  @override
  String get errorPasswordDigit => 'Şifre en az bir rakam içermeli.';

  @override
  String get errorPasswordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get genreNovel => 'Roman';

  @override
  String get genreScience => 'Bilim';

  @override
  String get genreHistory => 'Tarih';

  @override
  String get genrePhilosophy => 'Felsefe';

  @override
  String get genrePersonalDevelopment => 'Kişisel Gelişim';

  @override
  String get genreSciFiFantasy => 'Bilim Kurgu & Fantastik';

  @override
  String get genreBiography => 'Biyografi';

  @override
  String get genrePoetry => 'Şiir';

  @override
  String get genreChildren => 'Çocuk';

  @override
  String get genreOther => 'Diğer';

  @override
  String get statusToRead => 'Okunacak';

  @override
  String get statusReading => 'Okunuyor';

  @override
  String get statusFinished => 'Bitti';

  @override
  String get themeDark => 'Karanlık';

  @override
  String get themeLight => 'Aydınlık';

  @override
  String pageProgress(int current, int total) {
    return '$current / $total sayfa';
  }

  @override
  String progressPercent(int percent) {
    return '%$percent';
  }

  @override
  String progressSemantics(int percent) {
    return 'Okuma ilerlemesi yüzde $percent';
  }

  @override
  String ratingStarSemantics(int star) {
    return '$star yıldız ver';
  }

  @override
  String get splashError => 'Veriler yüklenemedi.';

  @override
  String get authTagline => 'Sanal kütüphanen, cebinde.';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get fieldEmail => 'E-posta';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get hintPhone => '0 (5XX) XXX XX XX';

  @override
  String get fieldPassword => 'Şifre';

  @override
  String get fieldPasswordConfirm => 'Şifre Tekrar';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get buttonRegister => 'Kayıt Ol';

  @override
  String get buttonLogin => 'Giriş Yap';

  @override
  String get linkHaveAccount => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get linkNoAccount => 'Hesabın yok mu? Kayıt ol';

  @override
  String get linkForgotPassword => 'Şifremi unuttum';

  @override
  String get forgotTitle => 'Şifreni Sıfırla';

  @override
  String get forgotVerifyInfo =>
      'Kayıt olurken kullandığın e-posta adresini ve telefon numarasını gir.';

  @override
  String get forgotVerifyButton => 'Devam';

  @override
  String get forgotBackToLogin => 'Girişe dön';

  @override
  String forgotNewPasswordInfo(String email) {
    return '$email hesabı doğrulandı. Yeni şifreni belirle.';
  }

  @override
  String get forgotResetButton => 'Şifreyi Güncelle';

  @override
  String get forgotBack => 'Geri';

  @override
  String get forgotSuccess =>
      'Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.';

  @override
  String get errorRecoveryMismatch =>
      'E-posta veya telefon kayıtlı bilgilerle eşleşmedi.';

  @override
  String errorTooManyAttempts(int seconds) {
    return 'Çok fazla hatalı deneme yaptın. $seconds saniye sonra tekrar dene.';
  }

  @override
  String get errorInvalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get errorWrongCurrentPassword => 'Mevcut şifre hatalı.';

  @override
  String get navLibrary => 'Kitaplığım';

  @override
  String get navReadingStatus => 'Okuma Durumu';

  @override
  String get navGoal => 'Hedef';

  @override
  String get navLoans => 'Ödünç';

  @override
  String navLoansOverdue(int count) {
    return 'Ödünç: $count gecikmiş iade';
  }

  @override
  String get loansTitle => 'Ödünç Takibi';

  @override
  String get libraryTitle => 'Kitaplığım';

  @override
  String get readingStatusTitle => 'Okuma Durumu';

  @override
  String get readingGoalTitle => 'Yıllık Okuma Hedefi';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsNotificationsTitle => 'Bildirimler';

  @override
  String get settingsLoanReminders => 'İade hatırlatmaları';

  @override
  String get settingsLoanRemindersHint =>
      'Ödünç verdiğin kitabın iade gününden bir gün önce ve iade günü saat 10:00\'da bildirim gönderir.';

  @override
  String get settingsLoanRemindersDenied =>
      'Bildirim izni kapalı. Hatırlatmaları görmek için telefonun ayarlarından Kitalog bildirimlerini aç.';

  @override
  String get settingsReadingReminders => 'Günlük okuma hatırlatması';

  @override
  String get settingsReadingRemindersHint =>
      'Her gün seçtiğin saatte okumaya davet eder; o gün okuduysan bildirim gelmez. Art arda okuduğun günlerde serini hatırlatır.';

  @override
  String get settingsStalledReminders => 'Yarım kalan kitaplar';

  @override
  String settingsStalledRemindersHint(int days) {
    return '“Okunuyor” durumundaki bir kitapta $days gün ilerleme olmazsa seçtiğin saatte bir kez hatırlatır.';
  }

  @override
  String get settingsReadingReminderTime => 'Okuma hatırlatması saati';

  @override
  String get libraryFilters => 'Filtreler';

  @override
  String libraryFiltersActive(int count) {
    return 'Filtreler ($count seçili)';
  }

  @override
  String get libraryFilterFormat => 'Biçim';

  @override
  String get libraryFilterGenre => 'Tür';

  @override
  String get libraryFilterClear => 'Temizle';

  @override
  String get libraryFilterRemove => 'Filtreyi kaldır';

  @override
  String libraryShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kitabı göster',
      zero: 'Eşleşen kitap yok',
    );
    return '$_temp0';
  }

  @override
  String get librarySearchHint => 'Başlık veya yazar ara';

  @override
  String get libraryAddBook => 'Kitap Ekle';

  @override
  String get libraryEmptyTitle => 'Kitaplığın henüz boş';

  @override
  String get libraryEmptyMessage =>
      'İlk kitabını eklemek için “Kitap Ekle” düğmesine dokun.';

  @override
  String get libraryNoResultsTitle => 'Sonuç bulunamadı';

  @override
  String get libraryNoResultsMessage =>
      'Arama veya filtreleri değiştirmeyi dene.';

  @override
  String get physicalBadge => 'Fiziksel';

  @override
  String get digitalBadge => 'Dijital';

  @override
  String get loanedBadge => 'Ödünçte';

  @override
  String get bookDetailTitle => 'Kitap Detayı';

  @override
  String get bookNotFound => 'Kitap bulunamadı.';

  @override
  String get authorUnknown => 'Yazar bilinmiyor';

  @override
  String bookPageCount(int count) {
    return '$count sayfa';
  }

  @override
  String bookIsbn(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String get bookOwned => 'Fiziksel kopyası bende';

  @override
  String get bookNotOwned => 'Fiziksel kopyası yok';

  @override
  String get pageCounterTitle => 'Okuma İlerlemesi';

  @override
  String get pageEditTooltip => 'Sayfa numarasını gir';

  @override
  String get pageEditTitle => 'Mevcut sayfa';

  @override
  String pageEditLabel(int max) {
    return 'Sayfa (0 - $max)';
  }

  @override
  String get pageDecrement => '1 sayfa geri';

  @override
  String get pageIncrement => '1 sayfa ileri';

  @override
  String pageDecrementBig(int count) {
    return '$count sayfa geri';
  }

  @override
  String pageIncrementBig(int count) {
    return '$count sayfa ileri';
  }

  @override
  String get finishReachedMessage =>
      'Son sayfaya ulaştın. Kitap \"Bitti\" olarak işaretlenecek ve bu yılın okuma hedefine sayılacak.';

  @override
  String get markFinished => 'Bitti olarak işaretle';

  @override
  String get statusSectionTitle => 'Okuma Durumu';

  @override
  String startedAtLabel(String date) {
    return 'Başlangıç: $date';
  }

  @override
  String finishedAtLabel(String date) {
    return 'Bitiş: $date';
  }

  @override
  String get ratingSectionTitle => 'Puan ve İnceleme';

  @override
  String get reviewEdit => 'İncelemeyi düzenle';

  @override
  String get reviewDialogTitle => 'Şahsi İnceleme';

  @override
  String get reviewHint => 'İncelemeni yaz';

  @override
  String get reviewEmpty => 'Henüz inceleme yazmadın.';

  @override
  String get quotesSectionTitle => 'Alıntılar';

  @override
  String get quotesEmpty => 'Henüz alıntı eklenmedi.';

  @override
  String get quoteAdd => 'Alıntı Ekle';

  @override
  String get quoteText => 'Alıntı metni';

  @override
  String get quotePage => 'Sayfa no (isteğe bağlı)';

  @override
  String quotePageLabel(int page) {
    return 's. $page';
  }

  @override
  String get quoteFavorite => 'Favorilere ekle';

  @override
  String get quoteUnfavorite => 'Favorilerden çıkar';

  @override
  String get quoteDelete => 'Alıntıyı sil';

  @override
  String get notesSectionTitle => 'Notlar';

  @override
  String get notesEmpty => 'Henüz not eklenmedi.';

  @override
  String get noteAdd => 'Not Ekle';

  @override
  String get noteContent => 'Not';

  @override
  String get noteDelete => 'Notu sil';

  @override
  String get loanSectionTitle => 'Ödünç Bilgisi';

  @override
  String get loanNone => 'Bu kitap ödünç verilmedi.';

  @override
  String get loanLend => 'Ödünç Ver';

  @override
  String get loanBorrower => 'Kime ödünç verildi?';

  @override
  String get loanDueDate => 'İade tarihi seç (isteğe bağlı)';

  @override
  String get loanClearDate => 'Tarihi temizle';

  @override
  String loanLentTo(String name) {
    return '$name kişisine ödünç verildi';
  }

  @override
  String loanLentAt(String date) {
    return 'Veriliş tarihi: $date';
  }

  @override
  String loanDueAt(String date) {
    return 'İade tarihi: $date';
  }

  @override
  String get loanOverdue => 'İade tarihi geçti';

  @override
  String get loanReturn => 'İade alındı';

  @override
  String get loansTabActive => 'Ödünçte';

  @override
  String get loansTabHistory => 'Geçmiş';

  @override
  String get loansSummaryActive => 'Ödünçte';

  @override
  String get loansSummaryOverdue => 'Gecikmiş';

  @override
  String get loansSummaryDueSoon => 'İadesi yaklaşan';

  @override
  String loansDaysOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gündür ödünçte',
      zero: 'bugün verildi',
    );
    return '$_temp0';
  }

  @override
  String get loansDueNone => 'İade tarihi yok';

  @override
  String get loansDueToday => 'Bugün iade edilmeli';

  @override
  String loansDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'İadeye $count gün kaldı',
      one: 'Yarın iade edilmeli',
    );
    return '$_temp0';
  }

  @override
  String loansOverdueBy(int count) {
    return '$count gün gecikti';
  }

  @override
  String get loansEdit => 'Düzenle';

  @override
  String get loansEditTitle => 'Ödünç Bilgisini Düzenle';

  @override
  String get loansReturnConfirmTitle => 'İade alındı mı?';

  @override
  String loansReturnConfirmMessage(String title, String name) {
    return '“$title”, $name kişisinden geri alındı olarak işaretlenecek ve ödünç geçmişine eklenecek.';
  }

  @override
  String get loansPickBookTitle => 'Ödünç verilecek kitabı seç';

  @override
  String get loansNoLendableTitle => 'Ödünç verilebilecek kitap yok';

  @override
  String get loansNoLendableMessage =>
      'Fiziksel kopyası sende olan ve şu an ödünçte olmayan kitaplar burada listelenir.';

  @override
  String get loansEmptyActiveTitle => 'Ödünçte kitap yok';

  @override
  String get loansEmptyActiveMessage =>
      'Fiziksel bir kitabını ödünç verdiğinde kime verdiğini ve iade tarihini burada takip edebilirsin.';

  @override
  String get loansEmptyHistoryTitle => 'Ödünç geçmişi boş';

  @override
  String get loansEmptyHistoryMessage =>
      'İadesini aldığın kitaplar burada listelenir.';

  @override
  String loansHistoryPeriod(String lent, String returned) {
    return '$lent – $returned';
  }

  @override
  String loansHistoryDuration(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
      zero: 'aynı gün',
    );
    return '$_temp0';
  }

  @override
  String get loansReturnedLate => 'Geç iade edildi';

  @override
  String get loanReminderChannelName => 'Ödünç hatırlatmaları';

  @override
  String get loanReminderChannelDescription =>
      'Ödünç verdiğin kitapların iade günü yaklaşınca hatırlatır.';

  @override
  String get loanReminderTomorrowTitle => 'Yarın iade günü';

  @override
  String get loanReminderTodayTitle => 'Bugün iade günü';

  @override
  String loanReminderBody(String title, String name) {
    return '$name, “$title” kitabını geri getirmeli.';
  }

  @override
  String get readingReminderChannelName => 'Okuma hatırlatmaları';

  @override
  String get readingReminderChannelDescription =>
      'Her gün seçtiğin saatte okumaya davet eder ve yarım kalan kitapları hatırlatır.';

  @override
  String get readingReminderTitle => 'Okuma zamanı';

  @override
  String readingReminderBody(String title, int page) {
    return '“$title” kitabında $page. sayfadasın. 10 dakika okumaya ne dersin?';
  }

  @override
  String readingReminderBodyStart(String title) {
    return '“$title” seni bekliyor. 10 dakika okumaya ne dersin?';
  }

  @override
  String get readingReminderBodyNoBook =>
      'Bugün birkaç sayfa okumaya ne dersin? Kitaplığında seni bekleyen kitaplar var.';

  @override
  String readingReminderStreakTitle(int days) {
    return '$days gündür okuyorsun, seriyi bozma!';
  }

  @override
  String get readingReminderStalledTitle => 'Yarım kalan kitap';

  @override
  String readingReminderStalledBody(String title, int days) {
    return '“$title” kitabında $days gündür ilerleme yok. Kaldığın yerden devam etmeye ne dersin?';
  }

  @override
  String get deleteBook => 'Kitabı sil';

  @override
  String get deleteBookTitle => 'Kitap silinsin mi?';

  @override
  String deleteBookMessage(String title) {
    return '“$title” ve ona ait alıntı ile notlar kalıcı olarak silinecek.';
  }

  @override
  String readingTabLabel(String status, int count) {
    return '$status ($count)';
  }

  @override
  String get readingEmptyReadingTitle => 'Şu an okuduğun kitap yok';

  @override
  String get readingEmptyReadingMessage =>
      'Okunacak listenden bir kitap seçip okumaya başla.';

  @override
  String get readingEmptyToReadTitle => 'Okunacak listen boş';

  @override
  String get readingEmptyToReadMessage =>
      'Kitaplığından bir kitabı “Okunacak” olarak işaretle.';

  @override
  String get readingEmptyFinishedTitle => 'Henüz bitirdiğin kitap yok';

  @override
  String get readingEmptyFinishedMessage =>
      'Bitirdiğin kitaplar burada görünecek.';

  @override
  String get startReading => 'Okumaya Başla';

  @override
  String get errorPageCountInvalid =>
      'Sayfa sayısı 1 veya daha büyük bir sayı olmalı.';

  @override
  String get errorUrlInvalid => 'Geçerli bir http/https adresi girin.';

  @override
  String get errorIsbnInvalid => 'Geçerli bir ISBN girin (10 veya 13 hane).';

  @override
  String get addBookTitle => 'Yeni Kitap Ekle';

  @override
  String get addBookModeSearch => 'ISBN / Arama';

  @override
  String get addBookModeManual => 'Manuel';

  @override
  String get addBookSearchLabel => 'ISBN, başlık veya yazar';

  @override
  String get addBookSearchHint => 'Örn. 9780375508325 veya Cosmos';

  @override
  String get addBookSearchButton => 'Ara';

  @override
  String get addBookSearchEmptyTitle => 'Open Library\'de kitap ara';

  @override
  String get addBookSearchEmptyMessage =>
      'ISBN numarası ya da başlık/yazar yazıp ara. Bulamazsan manuel ekleyebilirsin.';

  @override
  String get addBookErrorEmptyQuery =>
      'Aramak için bir ISBN, başlık veya yazar yaz.';

  @override
  String get addBookErrorInvalidIsbn =>
      'Bu ISBN geçerli değil. Rakamları kontrol et.';

  @override
  String get addBookErrorNotFound =>
      'Sonuç bulunamadı. Kitabı manuel ekleyebilirsin.';

  @override
  String get addBookErrorNetwork => 'İnternet bağlantısı kurulamadı.';

  @override
  String get addBookErrorServer => 'Open Library şu an yanıt vermiyor.';

  @override
  String get addBookErrorDuplicate =>
      'Bu ISBN ile kayıtlı bir kitap zaten var.';

  @override
  String get addBookGoManual => 'Manuel Ekle';

  @override
  String get addBookSave => 'Kitaplığa Ekle';

  @override
  String get addBookSaved => 'Kitap kitaplığa eklendi.';

  @override
  String get fieldBookTitle => 'Kitap adı';

  @override
  String get fieldBookAuthors => 'Yazar(lar)';

  @override
  String get fieldBookAuthorsHelper => 'Birden fazla yazarı virgülle ayır.';

  @override
  String get fieldBookPages => 'Sayfa sayısı';

  @override
  String get genreAdd => 'Yeni kategori ekle';

  @override
  String get genreNewTitle => 'Yeni kategori';

  @override
  String get genreNewName => 'Kategori adı';

  @override
  String get genreNewColor => 'Renk';

  @override
  String genreColorOption(int number) {
    return 'Renk $number';
  }

  @override
  String get genreNewSave => 'Ekle';

  @override
  String get errorGenreNameTooLong =>
      'Kategori adı en fazla 30 karakter olabilir.';

  @override
  String get errorGenreNameTaken =>
      'Bu kategori zaten var; listeden seçebilirsin.';

  @override
  String get fieldBookGenre => 'Tür';

  @override
  String get fieldBookStatus => 'Okuma durumu';

  @override
  String get fieldBookIsbn => 'ISBN (isteğe bağlı)';

  @override
  String get fieldBookCover => 'Kapak';

  @override
  String get coverFromGallery => 'Galeriden seç';

  @override
  String get coverFromCamera => 'Fotoğraf çek';

  @override
  String get coverRemove => 'Resmi kaldır';

  @override
  String get coverFromDeviceSelected =>
      'Cihazdan seçilen resim kapak olarak kullanılacak.';

  @override
  String get coverPickFailed => 'Resim seçilemedi. Lütfen tekrar dene.';

  @override
  String get fieldBookCoverUrl => 'Kapak URL (isteğe bağlı)';

  @override
  String get fieldBookOwned => 'Bu kitap bende fiziksel olarak var';

  @override
  String goalYearLabel(int year) {
    return '$year Okuma Hedefi';
  }

  @override
  String goalProgress(int finished, int target) {
    return '$finished / $target kitap';
  }

  @override
  String goalRemaining(int count) {
    return 'Hedefe $count kitap kaldı';
  }

  @override
  String get goalCompleted => 'Yıllık hedefine ulaştın, tebrikler!';

  @override
  String goalTarget(int target) {
    return 'Hedef: $target kitap';
  }

  @override
  String get goalDecrease => 'Hedefi azalt';

  @override
  String get goalIncrease => 'Hedefi artır';

  @override
  String get goalTotalPages => 'Toplam okunan sayfa';

  @override
  String get goalMonthlyTitle => 'Aylık biten kitaplar';

  @override
  String goalMonthSemantics(String month, int count) {
    return '$month: $count kitap';
  }

  @override
  String get goalGenreTitle => 'Türlere göre dağılım';

  @override
  String get goalGenreEmpty => 'Bu yıl henüz biten kitap yok.';

  @override
  String get profileAvatar => 'Profil resmi';

  @override
  String get profileChangeAvatar => 'Profil resmini değiştir';

  @override
  String profileMemberSince(String date) {
    return 'Üyelik: $date';
  }

  @override
  String get avatarPresetTitle => 'Hazır avatar seç';

  @override
  String get avatarFromGallery => 'Galeriden yükle';

  @override
  String get avatarFromCamera => 'Kamerayla çek';

  @override
  String get avatarRemove => 'Profil resmini kaldır';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsLanguageTitle => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsUpdateEmail => 'E-posta adresini güncelle';

  @override
  String get settingsUpdatePhone => 'Telefon numarasını güncelle';

  @override
  String get settingsUpdatePassword => 'Şifreyi güncelle';

  @override
  String get fieldCurrentPassword => 'Mevcut şifre';

  @override
  String get fieldNewPassword => 'Yeni şifre';

  @override
  String get settingsEmailSaved => 'E-posta güncellendi.';

  @override
  String get settingsPhoneSaved => 'Telefon güncellendi.';

  @override
  String get settingsPasswordSaved => 'Şifre güncellendi.';

  @override
  String get settingsAvatarSaved => 'Profil resmi güncellendi.';

  @override
  String get settingsAvatarFailed => 'Resim seçilemedi. Lütfen tekrar dene.';

  @override
  String get settingsLogout => 'Çıkış Yap';

  @override
  String get settingsLogoutTitle => 'Çıkış yapılsın mı?';

  @override
  String get settingsLogoutMessage =>
      'Verilerin silinmez; tekrar giriş yapabilirsin.';

  @override
  String get readerDownloadTitle => 'Bu kitap henüz cihazında değil';

  @override
  String get readerDownloadMessage =>
      'Bir kez indir; sonra internet olmadan da okuyabilirsin.';

  @override
  String get readerDownloadWebNote =>
      'Web sürümünde metin yalnızca bu oturum boyunca saklanır; çevrimdışı okuma için mobil uygulamayı kullan.';

  @override
  String get readerDownloadButton => 'İndir ve Oku';

  @override
  String readerDownloading(int percent) {
    return 'İndiriliyor… %$percent';
  }

  @override
  String get readerErrorNetwork =>
      'İnternet bağlantısı kurulamadı. İndirmek için bağlantı gerekiyor.';

  @override
  String get readerErrorServer =>
      'Kaynak şu an yanıt vermiyor. Biraz sonra tekrar dene.';

  @override
  String get readerErrorNotFound => 'Bu kitabın metni kaynağında bulunamadı.';

  @override
  String get readerErrorStorage =>
      'Metin cihaza kaydedilemedi. Depolama alanını kontrol et.';

  @override
  String get readerErrorUnavailable =>
      'Bu kitabın ücretsiz dijital sürümü yok.';

  @override
  String readerPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get readerPrevious => 'Önceki sayfa';

  @override
  String get readerNext => 'Sonraki sayfa';

  @override
  String get readerQuoteSave => 'Alıntı olarak kaydet';

  @override
  String get readerQuoteSaved =>
      'Alıntı kaydedildi; kitap ayrıntılarındaki Alıntılar bölümüne eklendi.';

  @override
  String get readerQuoteDuplicate => 'Bu alıntı zaten kayıtlı.';

  @override
  String get readerTranslate => 'Çeviri';

  @override
  String get readerTranslateSelection => 'Çevir';

  @override
  String get readerTranslationOriginal => 'Orijinal';

  @override
  String get readerTranslationTurkish => 'Türkçe çeviri';

  @override
  String get readerTranslationEnglish => 'İngilizce çeviri';

  @override
  String get readerTranslationBoth => 'Orijinal ve çeviri alt alta';

  @override
  String get readerTranslationTranslating => 'Sayfa çevriliyor…';

  @override
  String get readerTranslationDownloading => 'Çeviri dil paketi indiriliyor…';

  @override
  String get readerTranslationModelTitle => 'Çeviri dil paketi indirilsin mi?';

  @override
  String get readerTranslationModelMessage =>
      'Çeviri cihazında yapılır. Bunun için İngilizce ve Türkçe dil paketlerinin bir kez indirilmesi gerekir (yaklaşık 30 MB). Sonra çeviri internet olmadan da çalışır.';

  @override
  String get readerTranslationModelDownload => 'İndir';

  @override
  String get readerTranslationErrorModel =>
      'Dil paketi indirilemedi. İnternet bağlantını kontrol edip tekrar dene.';

  @override
  String get readerTranslationErrorTranslate => 'Metin çevrilemedi.';

  @override
  String get readerTranslationNote =>
      'Cihazda yapılan otomatik çeviridir; hatalar içerebilir.';

  @override
  String get readerTranslationCopy => 'Kopyala';

  @override
  String get readerTranslationCopied => 'Çeviri kopyalandı.';

  @override
  String get readerTextSize => 'Yazı boyutu';

  @override
  String readerTextScaleValue(int percent) {
    return '%$percent';
  }

  @override
  String get digitalSectionTitle => 'Dijital Sürüm';

  @override
  String get digitalDownload => 'İndir (çevrimdışı okuma)';

  @override
  String get digitalRead => 'Oku';

  @override
  String get digitalDelete => 'Cihazdan sil';

  @override
  String get fileErrorUnsupported =>
      'Yalnızca PDF ve EPUB dosyaları desteklenir.';

  @override
  String get fileErrorInvalid =>
      'Dosya açılamadı; bozuk ya da geçersiz bir PDF/EPUB olabilir.';

  @override
  String get fileErrorProtected =>
      'Bu dosya kopya korumalı (DRM); korumalı kitaplar açılamaz.';

  @override
  String get fileErrorTooLarge => 'Dosya çok büyük (en fazla 150 MB).';

  @override
  String get fileErrorMissing =>
      'Dosya bu cihazda bulunamadı. Kitap detayından yeniden yükleyebilirsin.';

  @override
  String get digitalImportHint =>
      'Kendi PDF veya EPUB dosyanı yükleyip uygulamada okuyabilirsin. Dosya yalnızca bu cihazda saklanır.';

  @override
  String get digitalImportButton => 'Dosya yükle (PDF / EPUB)';

  @override
  String get digitalImporting => 'Dosya hazırlanıyor…';

  @override
  String get digitalReplaceFile => 'Başka dosya yükle';

  @override
  String statusCurrentLabel(String status) {
    return 'Durum: $status';
  }

  @override
  String get readAgain => 'Tekrar Oku';

  @override
  String get finishConfirmTitle => 'Kitabı bitirdin mi?';

  @override
  String get finishConfirmMessage =>
      'Kitap \"Bitti\" olarak işaretlenecek ve okuma ilerlemesi son sayfaya getirilecek.';

  @override
  String get readAgainConfirmTitle => 'Kitabı tekrar oku?';

  @override
  String get readAgainConfirmMessage =>
      'Okuma ilerlemesi sıfırlanacak ve kitap \"Okunuyor\" durumuna geçecek. Yeniden bitirene kadar yıllık hedefte sayılmaz.';
}
