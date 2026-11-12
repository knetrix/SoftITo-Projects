import 'package:intl/intl.dart';

/// Saat kaynağı; testler sabit bir an verir (golden'lar zamana bağlı olmasın).
DateTime Function() clockNow = DateTime.now;

String _pad(int n) => n.toString().padLeft(2, '0');

/// '21:00' → '21:00–22:00'
String timeRange(String start) {
  final h = int.tryParse(start.split(':').first) ?? 0;
  return '$start–${_pad(h + 1)}:00';
}

/// '21:00–22:00' → '21:00'
String rangeStart(String range) => range.split('–').first;

/// Gündüz = başlangıç 06:00–16:00 dahil (§3 ekran 05; prototip `h >= 6 && h < 17`).
bool isDaytime(String start) {
  final h = int.tryParse(start.split(':').first) ?? 0;
  return h >= 6 && h < 17;
}

/// "X dk önce" türü göreli zaman. Değerler ARB anahtarı + sayı olarak döner.
({String key, int n}) agoParts(DateTime at, {DateTime? now}) {
  final m = ((now ?? clockNow()).difference(at).inSeconds / 60).round();
  if (m < 1) return (key: 'justNow', n: 0);
  if (m < 60) return (key: 'agoM', n: m);
  final h = (m / 60).round();
  if (h < 24) return (key: 'agoH', n: h);
  return (key: 'agoD', n: (h / 24).round());
}

/// Sohbet listesi zamanı: bugünse SS:DD, dünse "Dün" (null döner), değilse tarih.
String? chatClock(DateTime at, String locale, {DateTime? now}) {
  final n = now ?? clockNow();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(at.year, at.month, at.day);
  if (day == today) return '${_pad(at.hour)}:${_pad(at.minute)}';
  if (day == today.subtract(const Duration(days: 1))) return null;
  return DateFormat.yMMMd(locale).format(at);
}

/// Mesaj balonu saati SS:DD.
String hhmm(DateTime at) => '${_pad(at.hour)}:${_pad(at.minute)}';
