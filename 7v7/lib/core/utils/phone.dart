/// Telefonu 10 haneli biçime getirir (5XXXXXXXXX): `+90` / `0` öneki atılır.
String normPhone(String s) {
  var x = s.replaceAll(RegExp(r'\D'), '');
  if (x.length == 12 && x.startsWith('90')) x = x.substring(2);
  if (x.length == 11 && x.startsWith('0')) x = x.substring(1);
  return x;
}

/// TR cep telefonu: 10 hane, 5 ile başlar (§3 ekran 03).
bool phoneOk(String s) {
  final x = normPhone(s);
  return x.length == 10 && x.startsWith('5');
}

/// `05XX XXX XX XX` görünümü.
String formatPhone(String s) {
  final x = normPhone(s);
  if (x.length != 10) return s.trim();
  return '0${x.substring(0, 3)} ${x.substring(3, 6)} ${x.substring(6, 8)} ${x.substring(8)}';
}
