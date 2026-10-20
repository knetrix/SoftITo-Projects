/// Form doğrulamaları. Dönen değer `AppStrings` hata anahtarıdır
/// (`null` = geçerli); UI `context.tr(key)` ile çözer.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );
  static final RegExp _phoneRegex = RegExp(r'^0?5\d{9}$');
  static final RegExp _phoneNoise = RegExp(r'[\s()\-]');
  static final RegExp _cardNoise = RegExp(r'[\s-]');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'err_email_required';
    if (!_emailRegex.hasMatch(text)) return 'err_email_invalid';
    return null;
  }

  /// Boşluk, parantez ve tireyi temizler: `(0532) 123 45 67` -> `05321234567`.
  static String cleanPhone(String value) => value.replaceAll(_phoneNoise, '');

  /// Kayıt biçimi: başındaki 0 atılmış 10 hane (`5XXXXXXXXX`).
  static String normalizePhone(String value) {
    final cleaned = cleanPhone(value);
    return cleaned.startsWith('0') ? cleaned.substring(1) : cleaned;
  }

  static String? phone(String? value) {
    final cleaned = cleanPhone(value ?? '');
    if (cleaned.isEmpty) return 'err_phone_required';
    if (!_phoneRegex.hasMatch(cleaned)) return 'err_phone_invalid';
    return null;
  }

  /// Boş olamaz; en az 8 karakter, 1 büyük, 1 küçük harf ve 1 rakam.
  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'err_password_required';
    final strong = text.length >= 8 &&
        text.contains(RegExp(r'[A-Z]')) &&
        text.contains(RegExp(r'[a-z]')) &&
        text.contains(RegExp(r'\d'));
    return strong ? null : 'err_password_weak';
  }

  static String? passwordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) return 'err_password_confirm_required';
    return value == password ? null : 'err_password_mismatch';
  }

  static String? required(String? value) {
    return (value?.trim().isEmpty ?? true) ? 'err_field_required' : null;
  }

  /// Test kart numarası: 16 hane (Luhn kontrolü yapılmaz).
  static String? cardNumber(String? value) {
    final digits = (value ?? '').replaceAll(_cardNoise, '');
    if (digits.isEmpty) return 'err_card_required';
    if (digits.length != 16 || !_digitsOnly.hasMatch(digits)) {
      return 'err_card_invalid';
    }
    return null;
  }

  /// `AA/YY` biçimi, ay 01-12 ve süresi geçmemiş olmalı.
  static String? cardExpiry(String? value, {DateTime? now}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'err_expiry_required';
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(text);
    if (match == null) return 'err_expiry_invalid';
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'err_expiry_invalid';
    final current = now ?? DateTime.now();
    final expired = year < current.year ||
        (year == current.year && month < current.month);
    return expired ? 'err_expiry_past' : null;
  }

  static String? cvv(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'err_cvv_required';
    if (!RegExp(r'^\d{3}$').hasMatch(text)) return 'err_cvv_invalid';
    return null;
  }
}
