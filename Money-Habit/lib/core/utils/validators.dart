enum ValidationError {
  required,
  invalidEmail,
  invalidPhone,
  weakPassword,
  passwordMismatch,
}

abstract final class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _strongPasswordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  static ValidationError? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (!_emailRegex.hasMatch(v)) return ValidationError.invalidEmail;
    return null;
  }

  /// 05XX..., +905XX..., 5XX... -> 5XXXXXXXXX (10 hane)
  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    return digits;
  }

  static String formatPhone(String raw) {
    final digits = normalizePhone(raw);
    if (digits.length != 10) return raw;
    // 5XX XXX XX XX
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8, 10)}';
  }

  static ValidationError? phone(String? value) {
    final v = normalizePhone(value ?? '');
    if (v.isEmpty) return ValidationError.required;
    if (v.length != 10 || !v.startsWith('5')) {
      return ValidationError.invalidPhone;
    }
    return null;
  }

  static ValidationError? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (!_strongPasswordRegex.hasMatch(v)) return ValidationError.weakPassword;
    return null;
  }

  static ValidationError? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return ValidationError.required;
    if (value != original) return ValidationError.passwordMismatch;
    return null;
  }
}
