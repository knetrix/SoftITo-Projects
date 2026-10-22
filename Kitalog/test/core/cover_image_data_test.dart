import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/cover_image_data.dart';

import '../helpers/fake_cover_picker.dart';

void main() {
  test('resim data URI\'ye çevrilir, türü baytlardan bulunur ve geri çözülür', () {
    final png = CoverImageData.encode(tinyPng);
    expect(png, startsWith('data:image/png;base64,'));
    expect(CoverImageData.bytesOf(png), tinyPng);

    final jpeg = CoverImageData.encode(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2]));
    expect(jpeg, startsWith('data:image/jpeg;base64,'));
    expect(CoverImageData.bytesOf(jpeg), [0xFF, 0xD8, 0xFF, 0xE0, 1, 2]);
  });

  test('yalnızca data:image adresleri cihaz kapağı sayılır', () {
    expect(CoverImageData.isLocal(CoverImageData.encode(tinyPng)), isTrue);
    expect(CoverImageData.isLocal('https://covers.openlibrary.org/b/isbn/1-L.jpg'), isFalse);
    expect(CoverImageData.isLocal(null), isFalse);
    expect(CoverImageData.isLocal(''), isFalse);
  });

  test('bozuk data URI null döner', () {
    expect(CoverImageData.bytesOf('data:image/png;base64,%%%'), isNull);
  });
}
