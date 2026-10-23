import 'package:intl/intl.dart';

extension MoneyParsing on String {
  /// "1.250,50" -> 125050, "1250,5" -> 125050, "1250.5" -> 125050 ; geçersizse null
  /// Virgül varsa TR formatı kabul edilir (nokta = binlik ayırıcı).
  int? toKurus() {
    final input = trim();
    if (input.isEmpty) return null;
    final normalized = input.contains(',')
        ? input.replaceAll('.', '').replaceAll(',', '.')
        : input;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }
}

extension MoneyFormatting on int {
  /// 125050 -> "₺1.250,50" (tr) / "₺1,250.50" (en)
  String toCurrency(String localeCode) =>
      NumberFormat.currency(locale: localeCode, symbol: '₺').format(this / 100);
}
