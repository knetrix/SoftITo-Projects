import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/storage/digital_file_storage_io.dart';

void main() {
  test('dosya adı güvenli hale getirilir', () {
    expect(DigitalFileStorage.fileNameFor('seed-978/0:1'), 'seed-978_0_1.txt');
  });

  test('bellek içi depolama yazar, okur, siler', () async {
    final storage = MemoryDigitalFileStorage();
    expect(storage.isPersistent, isFalse);
    expect(await storage.read('a.txt'), isNull);
    await storage.write('a.txt', 'merhaba');
    expect(await storage.read('a.txt'), 'merhaba');
    expect(await storage.sizeOf('a.txt'), 7);
    await storage.delete('a.txt');
    expect(await storage.read('a.txt'), isNull);
  });

  test('dosya depolama metni UTF-8 dosyaya kalıcı yazar', () async {
    final temp = await Directory.systemTemp.createTemp('kitalog_test');
    addTearDown(() => temp.delete(recursive: true));
    final storage = IoDigitalFileStorage(baseDirectory: () async => temp);
    expect(storage.isPersistent, isTrue);
    await storage.write('kitap.txt', 'Kürk Mantolu Madonna — ş ğ ı');

    // Yeni örnek aynı klasörü okuyabilmeli (uygulama yeniden açılmış gibi).
    final reopened = IoDigitalFileStorage(baseDirectory: () async => temp);
    expect(await reopened.read('kitap.txt'), 'Kürk Mantolu Madonna — ş ğ ı');
    expect(await reopened.sizeOf('kitap.txt'), greaterThan(0));
    expect(File('${temp.path}/books/kitap.txt.part').existsSync(), isFalse);

    await reopened.delete('kitap.txt');
    expect(await reopened.read('kitap.txt'), isNull);
    expect(await reopened.sizeOf('kitap.txt'), 0);
  });

  test('baytlar (PDF) bellekte ve dosyada yazılıp okunur', () async {
    final bytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 1, 2, 3]);
    final memory = MemoryDigitalFileStorage();
    await memory.writeBytes('a.pdf', bytes);
    expect(await memory.readBytes('a.pdf'), bytes);
    expect(await memory.sizeOf('a.pdf'), 7);
    await memory.delete('a.pdf');
    expect(await memory.readBytes('a.pdf'), isNull);

    final temp = await Directory.systemTemp.createTemp('kitalog_pdf');
    addTearDown(() => temp.delete(recursive: true));
    final io = IoDigitalFileStorage(baseDirectory: () async => temp);
    await io.writeBytes('a.pdf', bytes);
    expect(await IoDigitalFileStorage(baseDirectory: () async => temp).readBytes('a.pdf'), bytes);
    expect(DigitalFileStorage.fileNameFor('k1', extension: 'pdf'), 'k1.pdf');
  });
}
