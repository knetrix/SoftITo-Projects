import 'package:flutter_test/flutter_test.dart';
import 'package:tiknow/core/utils/validators.dart';

void main() {
  group('email', () {
    test('boş ve hatalı biçim reddedilir', () {
      expect(Validators.email(''), 'err_email_required');
      expect(Validators.email(null), 'err_email_required');
      expect(Validators.email('abc'), 'err_email_invalid');
      expect(Validators.email('a@b'), 'err_email_invalid');
    });
    test('geçerli e-posta kabul edilir', () {
      expect(Validators.email('mustafa@example.com'), isNull);
      expect(Validators.email(' ali.veli+x@mail.co.uk '), isNull);
    });
  });

  group('telefon', () {
    test('5XXXXXXXXX ve 05XXXXXXXXX kabul edilir', () {
      expect(Validators.phone('5321234567'), isNull);
      expect(Validators.phone('05321234567'), isNull);
    });
    test('boşluk/parantez/tire temizlenir', () {
      expect(Validators.phone('(0532) 123 45-67'), isNull);
      expect(Validators.cleanPhone('(0532) 123 45-67'), '05321234567');
    });
    test('hatalı numaralar reddedilir', () {
      expect(Validators.phone(''), 'err_phone_required');
      expect(Validators.phone('4321234567'), 'err_phone_invalid');
      expect(Validators.phone('532123456'), 'err_phone_invalid');
      expect(Validators.phone('053212345678'), 'err_phone_invalid');
    });
    test('normalizePhone başındaki 0 atar', () {
      expect(Validators.normalizePhone('0532 123 45 67'), '5321234567');
      expect(Validators.normalizePhone('5321234567'), '5321234567');
    });
  });

  group('şifre', () {
    test('kurallar', () {
      expect(Validators.password(''), 'err_password_required');
      expect(Validators.password('Ab1'), 'err_password_weak');
      expect(Validators.password('abcdefg1'), 'err_password_weak'); // büyük yok
      expect(Validators.password('ABCDEFG1'), 'err_password_weak'); // küçük yok
      expect(Validators.password('Abcdefgh'), 'err_password_weak'); // rakam yok
      expect(Validators.password('Abcdefg1'), isNull);
    });
    test('tekrar eşleşmeli', () {
      expect(Validators.passwordConfirm('', 'Abcdefg1'),
          'err_password_confirm_required');
      expect(Validators.passwordConfirm('Abcdefg2', 'Abcdefg1'),
          'err_password_mismatch');
      expect(Validators.passwordConfirm('Abcdefg1', 'Abcdefg1'), isNull);
    });
  });

  group('kart', () {
    test('numara 16 hane', () {
      expect(Validators.cardNumber(''), 'err_card_required');
      expect(Validators.cardNumber('1234'), 'err_card_invalid');
      expect(Validators.cardNumber('4242 4242 4242 4242'), isNull);
    });
    test('son kullanma biçim ve süre', () {
      final now = DateTime(2026, 10, 21);
      expect(Validators.cardExpiry('', now: now), 'err_expiry_required');
      expect(Validators.cardExpiry('1226', now: now), 'err_expiry_invalid');
      expect(Validators.cardExpiry('13/30', now: now), 'err_expiry_invalid');
      expect(Validators.cardExpiry('09/26', now: now), 'err_expiry_past');
      expect(Validators.cardExpiry('10/26', now: now), isNull);
      expect(Validators.cardExpiry('01/30', now: now), isNull);
    });
    test('cvv 3 hane', () {
      expect(Validators.cvv(''), 'err_cvv_required');
      expect(Validators.cvv('12'), 'err_cvv_invalid');
      expect(Validators.cvv('123'), isNull);
    });
  });
}
