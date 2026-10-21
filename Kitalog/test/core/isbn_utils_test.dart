import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/isbn_utils.dart';

void main() {
  test('normalize tire ve boşlukları temizler, ISBN dışını reddeder', () {
    expect(IsbnUtils.normalize('978-0-375-50832-5'), '9780375508325');
    expect(IsbnUtils.normalize(' 0 375 50832 5 '), '0375508325');
    expect(IsbnUtils.normalize('080442957x'), '080442957X');
    expect(IsbnUtils.normalize('Cosmos'), isNull);
    expect(IsbnUtils.normalize('12345'), isNull);
  });

  test('ISBN-13 ve ISBN-10 sağlama toplamı doğrulanır', () {
    expect(IsbnUtils.isValid('9780375508325'), isTrue);
    expect(IsbnUtils.isValid('9780375508326'), isFalse);
    expect(IsbnUtils.isValid('0375508325'), isTrue);
    expect(IsbnUtils.isValid('0375508326'), isFalse);
    expect(IsbnUtils.isValid('080442957X'), isTrue);
    expect(IsbnUtils.isValid('abc'), isFalse);
  });
}
