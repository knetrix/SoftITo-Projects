import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/phone_input_formatter.dart';

TextEditingValue _apply(String old, String next) {
  return const PhoneInputFormatter().formatEditUpdate(
    TextEditingValue(text: old),
    TextEditingValue(text: next),
  );
}

void main() {
  test('rakamları 0 (5XX) XXX XX XX maskesine çevirir', () {
    expect(_apply('', '05321234567').text, '0 (532) 123 45 67');
  });

  test('0 ile başlamayan girişin başına 0 ekler', () {
    expect(_apply('', '5').text, '0 (5');
  });

  test('rakam olmayan karakterleri ve 11 haneden fazlasını atar', () {
    expect(_apply('', '0532abc123456789').text, '0 (532) 123 45 67');
  });

  test('ayraç silinirse son rakamı siler', () {
    expect(_apply('0 (532) ', '0 (532)').text, '0 (53');
  });

  test('dolu alana farklı bir numara yazılınca / yapıştırılınca son hane düşmez', () {
    // Rakam süzgecinden geçmiş tam numara, önceki biçimli metinden kısa ama rakamları farklı.
    expect(_apply('0 (532) 999 99 99', '05321234567').text, '0 (532) 123 45 67');
    expect(_apply('0 (532) 999 99 99', '0 (533) 111 22 33').text, '0 (533) 111 22 33');
  });
}
