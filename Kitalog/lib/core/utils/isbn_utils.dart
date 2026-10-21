/// ISBN-10 / ISBN-13 yardımcıları (saf fonksiyonlar).
abstract final class IsbnUtils {
  static final RegExp _isbn10 = RegExp(r'^\d{9}[\dX]$');
  static final RegExp _isbn13 = RegExp(r'^\d{13}$');

  /// Boşluk ve tireleri kaldırır; ISBN biçiminde değilse `null` döner.
  static String? normalize(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    return (_isbn10.hasMatch(cleaned) || _isbn13.hasMatch(cleaned))
        ? cleaned
        : null;
  }

  static bool isValid(String isbn) {
    if (_isbn13.hasMatch(isbn)) return _isValid13(isbn);
    if (_isbn10.hasMatch(isbn)) return _isValid10(isbn);
    return false;
  }

  static bool _isValid13(String isbn) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(isbn[i]) * (i.isEven ? 1 : 3);
    }
    return (10 - sum % 10) % 10 == int.parse(isbn[12]);
  }

  static bool _isValid10(String isbn) {
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final char = isbn[i];
      final value = char == 'X' ? 10 : int.parse(char);
      sum += value * (10 - i);
    }
    return sum % 11 == 0;
  }
}
