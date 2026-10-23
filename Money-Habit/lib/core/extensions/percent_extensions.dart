import 'package:intl/intl.dart';

extension PercentFormatting on int {
  /// 25 -> "%25" (tr) / "25%" (en)
  String toPercent(String localeCode) =>
      NumberFormat.percentPattern(localeCode).format(this / 100);
}
