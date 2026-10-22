/// Rutino tarih ve seri (streak) yardımcı fonksiyonları
class AppDateUtils {
  /// Tarihi 'YYYY-MM-DD' biçimine çevirir
  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Bugünün tarih dizesi ('YYYY-MM-DD')
  static String todayString() {
    return formatDate(DateTime.now());
  }

  /// Dünün tarih dizesi ('YYYY-MM-DD')
  static String yesterdayString() {
    return formatDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Verilen ISO veya YYYY-MM-DD dizesini okunabilir formata dönüştürür
  static String formatReadable(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  /// Son N günün tarih listesini ('YYYY-MM-DD') döner
  static List<String> lastDays(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final d = now.subtract(Duration(days: count - 1 - index));
      return formatDate(d);
    });
  }

  /// İki tarih arasındaki gün farkını hesaplar
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return (toDate.difference(fromDate).inHours / 24).round();
  }
}
