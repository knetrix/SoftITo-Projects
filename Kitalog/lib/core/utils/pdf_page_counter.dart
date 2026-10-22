import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// PDF'in sayfa sayısını görüntüleyici açmadan, yükleme anında okur (PDFium).
abstract final class PdfPageCounter {
  /// Sayfa sayısı; dosya açılamazsa 0 döner (sayı okuyucu ilk açılınca öğrenilir).
  static Future<int> count(Uint8List bytes) async {
    try {
      await pdfrxFlutterInitialize();
      final document = await PdfDocument.openData(bytes);
      final pages = document.pages.length;
      await document.dispose();
      return pages;
    } catch (_) {
      return 0;
    }
  }
}
