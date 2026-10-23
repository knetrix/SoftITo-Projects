import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/extensions/money_extensions.dart';
import 'package:money_habit_tracker/core/extensions/percent_extensions.dart';
import 'package:money_habit_tracker/core/utils/password_hasher.dart';
import 'package:money_habit_tracker/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('boş veya null e-posta required hatası döner', () {
      expect(Validators.email(null), ValidationError.required);
      expect(Validators.email(''), ValidationError.required);
      expect(Validators.email('   '), ValidationError.required);
    });

    test('geçersiz e-posta invalidEmail hatası döner', () {
      expect(Validators.email('test'), ValidationError.invalidEmail);
      expect(Validators.email('test@'), ValidationError.invalidEmail);
      expect(Validators.email('test@domain'), ValidationError.invalidEmail);
    });

    test('geçerli e-posta null döner', () {
      expect(Validators.email('ahmet@example.com'), isNull);
      expect(Validators.email('ali.veli@sirket.com.tr'), isNull);
    });
  });

  group('Validators - Phone', () {
    test('telefon normalizasyonu 0 ve +90 ön eklerini temizler', () {
      expect(Validators.normalizePhone('05551234567'), '5551234567');
      expect(Validators.normalizePhone('+905551234567'), '5551234567');
      expect(Validators.normalizePhone('555 123 45 67'), '5551234567');
    });

    test('boş telefon required hatası döner', () {
      expect(Validators.phone(null), ValidationError.required);
      expect(Validators.phone(''), ValidationError.required);
    });

    test('5 ile başlamayan veya 10 hane olmayan numara invalidPhone döner', () {
      expect(Validators.phone('2121234567'), ValidationError.invalidPhone);
      expect(Validators.phone('555123'), ValidationError.invalidPhone);
    });

    test('geçerli telefon null döner', () {
      expect(Validators.phone('0555 123 45 67'), isNull);
      expect(Validators.phone('+905321112233'), isNull);
      expect(Validators.phone('5059998877'), isNull);
    });
  });

  group('Validators - Password', () {
    test('boş şifre required hatası döner', () {
      expect(Validators.password(null), ValidationError.required);
      expect(Validators.password(''), ValidationError.required);
    });

    test('zayıf şifreler weakPassword döner', () {
      // 8 karakterden kısa
      expect(Validators.password('Ab1!'), ValidationError.weakPassword);
      // büyük harf yok
      expect(Validators.password('password123'), ValidationError.weakPassword);
      // küçük harf yok
      expect(Validators.password('PASSWORD123'), ValidationError.weakPassword);
      // rakam yok
      expect(Validators.password('PasswordTest'), ValidationError.weakPassword);
    });

    test('güçlü şifre null döner', () {
      expect(Validators.password('Password123'), isNull);
      expect(Validators.password('Guv3nliSifre!'), isNull);
    });

    test('şifre onayı eşleşmeyi doğrular', () {
      expect(
        Validators.confirmPassword('Password123', 'Password123'),
        isNull,
      );
      expect(
        Validators.confirmPassword('Mismatch123', 'Password123'),
        ValidationError.passwordMismatch,
      );
      expect(
        Validators.confirmPassword('', 'Password123'),
        ValidationError.required,
      );
    });
  });

  group('PasswordHasher', () {
    test('aynı şifre aynı SHA-256 hash üretir ve doğrulanır', () {
      final hash1 = PasswordHasher.hash('Gizli123');
      final hash2 = PasswordHasher.hash('Gizli123');
      expect(hash1, equals(hash2));
      expect(PasswordHasher.verify('Gizli123', hash1), isTrue);
      expect(PasswordHasher.verify('Yanlis123', hash1), isFalse);
    });
  });

  group('MoneyExtensions', () {
    test('toKurus TR ve standart formatları doğru çevirir', () {
      expect('1.250,50'.toKurus(), 125050);
      expect('1250,50'.toKurus(), 125050);
      expect('1250.50'.toKurus(), 125050);
      expect('100'.toKurus(), 10000);
      expect('0'.toKurus(), isNull);
      expect('-50'.toKurus(), isNull);
      expect('abc'.toKurus(), isNull);
      expect(''.toKurus(), isNull);
    });

    test('toCurrency kuruşu para birimi formatına çevirir', () {
      final formattedTr = 125050.toCurrency('tr');
      expect(formattedTr, contains('1.250,50'));
      expect(formattedTr, contains('₺'));
    });
  });
  group('PercentExtensions', () {
    test('toPercent yüzde işaretini dile göre konumlandırır', () {
      expect(25.toPercent('tr'), '%25');
      expect(25.toPercent('en'), '25%');
      expect(100.toPercent('en'), '100%');
    });
  });
}
