import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String get monthKey => '$year-${month.toString().padLeft(2, '0')}';

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get dateOnly => DateTime(year, month, day);

  String formatDate(String localeCode) =>
      DateFormat.yMMMd(localeCode).format(this);

  String formatMonthYear(String localeCode) =>
      DateFormat.yMMMM(localeCode).format(this);
}
