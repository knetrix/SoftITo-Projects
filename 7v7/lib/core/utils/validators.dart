import 'phone.dart';

/// Türkçe yerel ayara göre küçük harf (İ→i, I→ı).
String trLower(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Türkçe yerel ayara göre büyük harf (i→İ, ı→I).
String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// Boşlukları sadeleştirir: baş/son boşluk silinir, ardışık boşluklar teke iner.
String squish(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Form doğrulama sonuçları; `null` geçerli demektir. Değerler ARB anahtarlarıdır.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static bool isEmail(String s) => _email.hasMatch(s.trim());

  static String? firstName(String s) => squish(s).isEmpty ? 'eFirst' : null;
  static String? lastName(String s) => squish(s).isEmpty ? 'eLast' : null;
  static String? email(String s) => isEmail(s) ? null : 'eEmail';
  static String? phone(String s) => phoneOk(s) ? null : 'ePhone';

  static String? newPassword(String s) {
    if (s.isEmpty) return 'ePassword';
    if (s.length < 8) return 'ePwlen';
    return null;
  }

  static String? password(String s) => s.isEmpty ? 'ePassword' : null;

}

/// Aynı oyuncu iki mevkide mi (§5.2-2)? Soyadlardan biri boşsa yalnız ad,
/// ikisi de doluysa ad+soyad karşılaştırılır; büyük/küçük harf duyarsız (tr).
bool samePlayer(String firstA, String lastA, String firstB, String lastB) {
  if (trLower(squish(firstA)) != trLower(squish(firstB))) return false;
  final la = squish(lastA), lb = squish(lastB);
  return la.isEmpty || lb.isEmpty || trLower(la) == trLower(lb);
}
