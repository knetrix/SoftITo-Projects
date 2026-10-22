import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../repositories/digital_sources/source_http.dart';
import 'text_cleaner.dart';

/// EPUB (zip içinde XHTML bölümleri) dosyasından okuma sırasına göre düz metin
/// çıkarır: `META-INF/container.xml` → OPF paket dosyası → manifest + spine.
abstract final class EpubTextExtractor {
  static final RegExp _attr = RegExp(r'''([\w:\-]+)\s*=\s*("([^"]*)"|'([^']*)')''');

  static String extract(Uint8List bytes) => read(bytes).text;

  /// Metin ve dosyada tanımlıysa basılı baskının sayfa sayısı (EPUB 3 `nav`
  /// `page-list` veya EPUB 2 NCX `pageList`); tanımlı değilse `null`.
  static ({String text, int? pageCount}) read(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const DigitalBookException(DigitalBookFailure.invalidFile);
    }
    if (_isProtected(archive)) {
      throw const DigitalBookException(DigitalBookFailure.protectedFile);
    }
    final container = _read(archive, 'META-INF/container.xml');
    final opfPath = container == null
        ? null
        : RegExp(r'''full-path\s*=\s*["']([^"']+)["']''').firstMatch(container)?.group(1);
    final opf = opfPath == null ? null : _read(archive, opfPath);
    if (opfPath == null || opf == null) {
      throw const DigitalBookException(DigitalBookFailure.invalidFile);
    }
    final base = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';
    final buffer = StringBuffer();
    for (final href in _readingOrder(opf)) {
      final xhtml = _read(archive, _resolve(base, href));
      if (xhtml == null) continue;
      final body = xhtml.replaceAll(RegExp(r'<head\b.*?</head>', dotAll: true, caseSensitive: false), '');
      final text = TextCleaner.htmlToText(body);
      if (text.isNotEmpty) buffer.write('$text\n\n');
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) throw const DigitalBookException(DigitalBookFailure.invalidFile);
    return (text: text, pageCount: _printedPageCount(archive));
  }

  static final RegExp _pageListNav = RegExp(
    r'''<nav\b[^>]*epub:type\s*=\s*["'][^"']*page-list[^"']*["'][^>]*>(.*?)</nav>''',
    dotAll: true,
    caseSensitive: false,
  );

  /// Basılı sayfa listesindeki sayfa sayısı; liste yoksa `null`.
  static int? _printedPageCount(Archive archive) {
    for (final file in archive.files) {
      final name = file.name.toLowerCase();
      if (!file.isFile || !RegExp(r'\.(x?html?|ncx)$').hasMatch(name)) continue;
      final content = utf8.decode(file.content, allowMalformed: true);
      final count = name.endsWith('.ncx')
          ? RegExp(r'<pageTarget\b').allMatches(content).length
          : RegExp(r'<a\b').allMatches(_pageListNav.firstMatch(content)?.group(1) ?? '').length;
      if (count > 0) return count;
    }
    return null;
  }

  /// Spine sırasındaki XHTML bölümlerinin yolları; spine yoksa manifest sırası.
  static List<String> _readingOrder(String opf) {
    final manifest = <String, String>{};
    final documents = <String>[];
    for (final tag in RegExp(r'<item\b[^>]*>').allMatches(opf)) {
      final attrs = _attributes(tag.group(0)!);
      final id = attrs['id'];
      final href = attrs['href'];
      if (id == null || href == null) continue;
      manifest[id] = href;
      final type = attrs['media-type'] ?? '';
      if (type.contains('html')) documents.add(href);
    }
    final spine = [
      for (final tag in RegExp(r'<itemref\b[^>]*>').allMatches(opf))
        ?manifest[_attributes(tag.group(0)!)['idref']],
    ];
    return spine.isNotEmpty ? spine : documents;
  }

  static Map<String, String> _attributes(String tag) => {
    for (final m in _attr.allMatches(tag)) m.group(1)!: m.group(3) ?? m.group(4) ?? '',
  };

  /// Yalnızca font gizleme amaçlı şifreleme DRM sayılmaz; bölüm içerikleri
  /// şifreliyse dosya korumalıdır.
  static bool _isProtected(Archive archive) {
    final encryption = _read(archive, 'META-INF/encryption.xml');
    if (encryption != null) {
      final uris = RegExp(r'''URI\s*=\s*["']([^"']+)["']''').allMatches(encryption).map((m) => m.group(1)!.toLowerCase());
      if (uris.any((u) => !RegExp(r'\.(ttf|otf|woff2?)$').hasMatch(u))) return true;
    }
    return archive.findFile('META-INF/rights.xml') != null;
  }

  static String? _read(Archive archive, String path) {
    final file = archive.findFile(path);
    if (file == null || !file.isFile) return null;
    return utf8.decode(file.content, allowMalformed: true);
  }

  /// OPF klasörüne göreli yolu (`../Text/b1.xhtml`, `%20` kodlaması) çözer.
  static String _resolve(String base, String href) {
    final clean = Uri.decodeComponent(href.split('#').first);
    final parts = <String>[];
    for (final segment in '$base$clean'.split('/')) {
      if (segment == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else if (segment.isNotEmpty && segment != '.') {
        parts.add(segment);
      }
    }
    return parts.join('/');
  }
}
