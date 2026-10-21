import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:kitalog/features/book_detail/controllers/book_file_picker.dart';

/// Testler için bellekte gerçek bir EPUB (zip + container.xml + OPF + bölümler) üretir.
/// Bölümler manifest'te ters sırada listelenir; okuma sırası spine'dan gelmelidir.
Uint8List buildEpub({
  List<String> chapters = const ['Birinci bölümün metni.', 'İkinci bölümün metni.'],
  bool encrypted = false,
  bool fontObfuscationOnly = false,
}) {
  final archive = Archive();
  void add(String name, String content) => archive.addFile(ArchiveFile.bytes(name, utf8.encode(content)));
  add('mimetype', 'application/epub+zip');
  add(
    'META-INF/container.xml',
    '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
        '<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>',
  );
  final manifest = StringBuffer();
  final spine = StringBuffer();
  for (var i = chapters.length - 1; i >= 0; i--) {
    manifest.write('<item id="b$i" href="Text/b%20$i.xhtml" media-type="application/xhtml+xml"/>');
  }
  for (var i = 0; i < chapters.length; i++) {
    spine.write('<itemref idref="b$i"/>');
    add(
      'OEBPS/Text/b $i.xhtml',
      '<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title>Başlık $i</title></head>'
          '<body><h1>Bölüm ${i + 1}</h1><p>${chapters[i]}</p></body></html>',
    );
  }
  add(
    'OEBPS/content.opf',
    '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0">'
        '<manifest>$manifest<item id="css" href="style.css" media-type="text/css"/></manifest>'
        '<spine>$spine</spine></package>',
  );
  if (encrypted || fontObfuscationOnly) {
    final uri = fontObfuscationOnly ? 'OEBPS/Fonts/font.otf' : 'OEBPS/Text/b 0.xhtml';
    add(
      'META-INF/encryption.xml',
      '<encryption xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><EncryptedData>'
          '<CipherData><CipherReference URI="$uri"/></CipherData></EncryptedData></encryption>',
    );
  }
  return ZipEncoder().encodeBytes(archive);
}

/// `%PDF` imzasıyla başlayan sahte PDF baytları (görüntülenmez, yalnızca saklanır).
Uint8List fakePdfBytes() => Uint8List.fromList(utf8.encode('%PDF-1.7\n% sahte içerik\n%%EOF'));

/// Galeri yerine sabit dosya döndüren sahte dosya seçici.
class FakeBookFilePicker implements BookFilePicker {
  FakeBookFilePicker([this.file]);

  PickedBookFile? file;
  int calls = 0;

  @override
  Future<PickedBookFile?> pick() async {
    calls++;
    return file;
  }
}
