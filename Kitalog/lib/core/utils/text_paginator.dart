import 'package:flutter/foundation.dart';

/// Okuyucudaki tek bir sayfa: metindeki başlangıç konumu ve içeriği.
@immutable
class TextPage {
  const TextPage({required this.start, required this.text});

  final int start;
  final String text;
}

/// Metni paragraf sınırlarında sayfalara böler ve okuma konumunu
/// sayfa/yüzde/basılı sayfa arasında dönüştürür (saf fonksiyonlar).
abstract final class TextPaginator {
  static const int defaultPageChars = 1500;

  static List<TextPage> paginate(String text, {int targetChars = defaultPageChars}) {
    final pages = <TextPage>[];
    final length = text.length;
    var pos = _skipWhitespace(text, 0);
    while (pos < length) {
      var end = pos + targetChars;
      if (end >= length) {
        end = length;
      } else {
        end = _breakPoint(text, pos, targetChars);
      }
      final content = text.substring(pos, end).trim();
      if (content.isNotEmpty) pages.add(TextPage(start: pos, text: content));
      pos = _skipWhitespace(text, end);
    }
    return pages.isEmpty ? const [TextPage(start: 0, text: '')] : pages;
  }

  /// Hedef uzunluğun çevresinde önce paragraf, sonra satır, cümle ve boşluk arar.
  static int _breakPoint(String text, int pos, int target) {
    final min = pos + (target * 0.6).round();
    final max = (pos + (target * 1.3).round()).clamp(0, text.length);
    for (final separator in ['\n\n', '\n', '. ', ' ']) {
      final index = text.lastIndexOf(separator, max - separator.length);
      if (index >= min) return index + separator.length;
    }
    return pos + target;
  }

  static int _skipWhitespace(String text, int from) {
    var i = from;
    while (i < text.length && text.codeUnitAt(i) <= 32) {
      i++;
    }
    return i;
  }

  /// Verilen karakter konumunu içeren sayfanın sırası.
  static int pageIndexForOffset(List<TextPage> pages, int offset) {
    var index = 0;
    for (var i = 0; i < pages.length; i++) {
      if (pages[i].start <= offset) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  /// Sayfa okunduğunda ulaşılan ilerleme (0.0 - 1.0); son sayfada 1.0.
  static double progressAfterPage(List<TextPage> pages, int index, int totalChars) {
    if (pages.isEmpty || totalChars <= 0) return 0;
    if (index >= pages.length - 1) return 1;
    return (pages[index + 1].start / totalChars).clamp(0.0, 1.0);
  }

  /// İlerlemeyi kitabın basılı sayfa sayısına çevirir.
  static int printedPageFor(double progress, int pageCount) {
    if (pageCount <= 0) return 0;
    return (progress.clamp(0.0, 1.0) * pageCount).round().clamp(0, pageCount);
  }
}
