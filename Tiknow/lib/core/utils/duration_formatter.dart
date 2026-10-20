/// Süre biçimlendirme: `1 sa 30 dk` ve sayaç için `01:05:09`.
abstract final class DurationFormatter {
  static String minutes(
    int totalMinutes, {
    required String hourUnit,
    required String minuteUnit,
  }) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '$mins $minuteUnit';
    if (mins == 0) return '$hours $hourUnit';
    return '$hours $hourUnit $mins $minuteUnit';
  }

  /// Negatif saniye (süre aşımı) başına `+` almaz; çağıran işaretler.
  static String clock(int seconds) {
    final s = seconds.abs();
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }
}
