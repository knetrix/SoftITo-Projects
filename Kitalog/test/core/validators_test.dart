import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/validators.dart';

void main() {
  group('email', () {
    final cases = <String?, ValidationError?>{
      null: ValidationError.required,
      '': ValidationError.required,
      '   ': ValidationError.required,
      'abc': ValidationError.emailInvalid,
      'a@b': ValidationError.emailInvalid,
      'a@b.c': ValidationError.emailInvalid,
      'ali@ornek.com': null,
      '  ALI@Ornek.COM  ': null,
      'ali.veli+kitap@mail.example.org': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.email(input), expected);
      });
    });
  });

  group('phone', () {
    final cases = <String?, ValidationError?>{
      null: ValidationError.required,
      '': ValidationError.required,
      '0 (5': ValidationError.phoneInvalid,
      '0 (532) 123 45 6': ValidationError.phoneInvalid,
      '0 (432) 123 45 67': ValidationError.phoneInvalid,
      '1 (532) 123 45 67': ValidationError.phoneInvalid,
      '0 (532) 123 45 67': null,
      '05321234567': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.phone(input), expected);
      });
    });
  });

  group('password', () {
    final cases = <String?, ValidationError?>{
      null: ValidationError.required,
      '': ValidationError.required,
      'Ab1': ValidationError.passwordTooShort,
      'abcdefg1': ValidationError.passwordNoUppercase,
      'ABCDEFG1': ValidationError.passwordNoLowercase,
      'Abcdefgh': ValidationError.passwordNoDigit,
      'Abcdefg1': null,
      'Şifre123x': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.password(input), expected);
      });
    });
  });

  group('passwordConfirm', () {
    test('boş değer zorunlu hatası verir', () {
      expect(Validators.passwordConfirm('', 'Abcdefg1'), ValidationError.required);
    });
    test('eşleşmezse hata verir', () {
      expect(
        Validators.passwordConfirm('Abcdefg2', 'Abcdefg1'),
        ValidationError.passwordMismatch,
      );
    });
    test('eşleşirse null döner', () {
      expect(Validators.passwordConfirm('Abcdefg1', 'Abcdefg1'), isNull);
    });
  });

  group('positiveInt', () {
    final cases = <String?, ValidationError?>{
      null: ValidationError.required,
      '': ValidationError.required,
      '0': ValidationError.pageCountInvalid,
      '-3': ValidationError.pageCountInvalid,
      'abc': ValidationError.pageCountInvalid,
      '1': null,
      ' 250 ': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.positiveInt(input), expected);
      });
    });
  });

  group('optionalUrl', () {
    final cases = <String?, ValidationError?>{
      null: null,
      '': null,
      'abc': ValidationError.urlInvalid,
      'ftp://x.com/a.jpg': ValidationError.urlInvalid,
      'https://': ValidationError.urlInvalid,
      'https://covers.openlibrary.org/b/isbn/9780375508325-L.jpg': null,
      'http://ornek.com/kapak.png': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.optionalUrl(input), expected);
      });
    });
  });

  group('optionalIsbn', () {
    final cases = <String?, ValidationError?>{
      null: null,
      '': null,
      '12345': ValidationError.isbnInvalid,
      '9780375508326': ValidationError.isbnInvalid,
      '9780375508325': null,
      '978-0-375-50832-5': null,
      '0375508325': null,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        expect(Validators.optionalIsbn(input), expected);
      });
    });
  });
}
