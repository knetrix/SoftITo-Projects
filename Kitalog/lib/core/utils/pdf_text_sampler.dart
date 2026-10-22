import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// PDF'ten dil tanıma için örnek metin okur (PDFium). Kapak ve künye sayfaları
/// dilin tanınmasını zorlaştırdığı için birkaç sayfa sonrasından başlanır.
abstract final class PdfTextSampler {
  static const int _skipPages = 2;
  static const int _maxPages = 12;

  /// En fazla [maxChars] karakter; metin okunamazsa (taranmış PDF) boş döner.
  static Future<String> sample(Uint8List bytes, {int maxChars = 3000}) async {
    try {
      await pdfrxFlutterInitialize();
      final document = await PdfDocument.openData(bytes);
      final buffer = StringBuffer();
      final pages = document.pages;
      final start = pages.length > _skipPages * 2 ? _skipPages : 0;
      for (var i = start; i < pages.length && i < start + _maxPages; i++) {
        final text = await pages[i].loadText();
        buffer.writeln(text?.fullText ?? '');
        if (buffer.length >= maxChars) break;
      }
      await document.dispose();
      final text = buffer.toString().trim();
      return text.length > maxChars ? text.substring(0, maxChars) : text;
    } catch (_) {
      return '';
    }
  }
}
