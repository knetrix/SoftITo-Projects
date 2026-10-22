import '../models/custom_genre_model.dart';
import 'isbn_utils.dart';

/// Doğrulama sonuçları; metne çevirme `ValidationErrorX.message` ile yapılır.
enum ValidationError {
  required,
  emailInvalid,
  phoneInvalid,
  passwordTooShort,
  passwordNoUppercase,
  passwordNoLowercase,
  passwordNoDigit,
  passwordMismatch,
  pageCountInvalid,
  urlInvalid,
  isbnInvalid,
  genreNameTooLong,
  genreNameTaken,
}

/// Kayıt ve Ayarlar ekranlarında AYNI validator'lar kullanılır.
/// Saf fonksiyonlardır; geçerliyse `null` döner.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _upper = RegExp(r'\p{Lu}', unicode: true);
  static final RegExp _lower = RegExp(r'\p{Ll}', unicode: true);
  static final RegExp _digit = RegExp(r'\d');

  static const int minPasswordLength = 8;
  static const int phoneDigitCount = 11;

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static ValidationError? required(String? value) {
    return (value == null || value.trim().isEmpty)
        ? ValidationError.required
        : null;
  }

  static ValidationError? email(String? value) {
    final email = normalizeEmail(value ?? '');
    if (email.isEmpty) return ValidationError.required;
    return _emailRegex.hasMatch(email) ? null : ValidationError.emailInvalid;
  }

  /// Biçim: `0 (5XX) XXX XX XX` → 0 ile başlayan 11 hane, ikinci hane 5.
  static ValidationError? phone(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return ValidationError.required;
    final valid =
        digits.length == phoneDigitCount && digits.startsWith('05');
    return valid ? null : ValidationError.phoneInvalid;
  }

  static ValidationError? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return ValidationError.required;
    if (password.length < minPasswordLength) {
      return ValidationError.passwordTooShort;
    }
    if (!_upper.hasMatch(password)) return ValidationError.passwordNoUppercase;
    if (!_lower.hasMatch(password)) return ValidationError.passwordNoLowercase;
    if (!_digit.hasMatch(password)) return ValidationError.passwordNoDigit;
    return null;
  }

  /// Yeni kategori adı: boş olamaz, en fazla `CustomGenreModel.maxNameLength`
  /// karakter, [takenNames] (yerleşik tür etiketleri ve mevcut kategoriler)
  /// içinde büyük/küçük harf farkı gözetmeden bulunmamalı.
  static ValidationError? genreName(String? value, Iterable<String> takenNames) {
    final name = CustomGenreModel.cleanName(value ?? '');
    if (name.isEmpty) return ValidationError.required;
    if (name.length > CustomGenreModel.maxNameLength) return ValidationError.genreNameTooLong;
    final key = CustomGenreModel.nameKey(name);
    return takenNames.any((n) => CustomGenreModel.nameKey(n) == key) ? ValidationError.genreNameTaken : null;
  }

  /// 1 veya daha büyük tam sayı (sayfa sayısı için).
  static ValidationError? positiveInt(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return ValidationError.required;
    final number = int.tryParse(text);
    return (number == null || number < 1) ? ValidationError.pageCountInvalid : null;
  }

  /// Boş olabilir; doluysa http/https adresi olmalı.
  static ValidationError? optionalUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final valid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : ValidationError.urlInvalid;
  }

  /// Boş olabilir; doluysa geçerli ISBN-10/13 olmalı.
  static ValidationError? optionalIsbn(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final isbn = IsbnUtils.normalize(text);
    return (isbn != null && IsbnUtils.isValid(isbn)) ? null : ValidationError.isbnInvalid;
  }

  static ValidationError? passwordConfirm(String? value, String? original) {
    if (value == null || value.isEmpty) return ValidationError.required;
    return value == original ? null : ValidationError.passwordMismatch;
  }
}
