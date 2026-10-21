// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

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
  String get libraryTitle => 'Kitaplığım';

  @override
  String get readingStatusTitle => 'Okuma Durumu';

  @override
  String get readingGoalTitle => 'Yıllık Okuma Hedefi';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get libraryFilterAll => 'Tümü';

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
  String get bookOwned => 'Kitaplığımda';

  @override
  String get bookNotOwned => 'Kitaplığımda değil';

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
  String get finishSuggestion => 'Son sayfaya ulaştın. Kitabı bitirdin mi?';

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
  String get fieldBookGenre => 'Tür';

  @override
  String get fieldBookStatus => 'Okuma durumu';

  @override
  String get fieldBookIsbn => 'ISBN (isteğe bağlı)';

  @override
  String get fieldBookCoverUrl => 'Kapak URL (isteğe bağlı)';

  @override
  String get fieldBookOwned => 'Bu kitap bende var';

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
}
