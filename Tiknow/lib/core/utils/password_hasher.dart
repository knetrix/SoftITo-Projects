import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

/// Şifreler düz metin saklanmaz: SHA-256 + kullanıcıya özel salt.
abstract final class PasswordHasher {
  static String generateSalt([math.Random? random]) {
    final rng = random ?? math.Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
