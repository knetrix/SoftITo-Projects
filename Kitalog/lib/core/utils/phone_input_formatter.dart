import 'package:flutter/services.dart';

/// Telefon maskesi: `0 (5XX) XXX XX XX`. Yalnızca rakam kabul eder, en fazla
/// 11 hane tutar ve 0 ile başlamayan girişin başına 0 ekler.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  static const int maxDigits = 11;

  static String format(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write(digits[i]);
      } else {
        if (i == 1) buffer.write(' (');
        if (i == 4) buffer.write(') ');
        if (i == 7 || i == 9) buffer.write(' ');
        buffer.write(digits[i]);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    // Ayraç karakteri silinirse (rakam sayısı değişmedi) son rakamı sil.
    if (newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.isNotEmpty && digits[0] != '0') digits = '0$digits';
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    final text = format(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
