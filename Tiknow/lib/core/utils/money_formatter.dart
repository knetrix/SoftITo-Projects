/// TL biçimlendirme: `2,95 TL`, `1.250,00 TL`, birim fiyat için `2,95 TL/dk`.
abstract final class MoneyFormatter {
  static String number(double amount) {
    final cents = (amount * 100).round();
    final negative = cents < 0;
    final abs = cents.abs();
    final whole = (abs ~/ 100).toString();
    final fraction = (abs % 100).toString().padLeft(2, '0');
    final grouped = _groupThousands(whole);
    return '${negative ? '-' : ''}$grouped,$fraction';
  }

  static String format(double amount) => '${number(amount)} TL';

  /// [unit] çevrilmiş birimdir (`dk`, `km`).
  static String rate(double amount, String unit) =>
      '${number(amount)} TL/$unit';

  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
