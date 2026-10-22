import 'package:flutter/foundation.dart';

/// Okuyucudaki tek bir sayfa: metindeki başlangıç konumu ve içeriği.
@immutable
class TextPage {
  const TextPage({required this.start, required this.text});

  final int start;
  final String text;
}

/// Metni paragraf sınırlarında sayfalara böler ve karakter konumunu sayfa
/// sırasına dönüştürür (saf fonksiyonlar).
abstract final class TextPaginator {
  static const int defaultPageChars = 1500;

  /// Bir sayfaya düşen en az karakter. Metin kitabın sayfa sayısına bölünemeyecek
  /// kadar kısaysa (ör. kitabın bir bölümünü içeren dosya) kelimeler bölünmesin
  /// diye [paginateInto] yerine [paginate] kullanılır.
  static const int minPageChars = 300;

  /// Metin [pageCount] sayfaya kelime bölmeden dağıtılabilir mi?
  static bool fitsPageCount(String text, int pageCount) =>
      pageCount > 0 && text.length >= pageCount * minPageChars;

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

  /// Metni tam olarak [pageCount] sayfaya böler; böylece okuyucudaki sayfa
  /// numarası kitabın basılı sayfa sayacıyla birebir eşleşir. Her sınır eşit
  /// aralıklı ideal konumun çevresindeki en yakın paragraf / satır / cümle /
  /// boşlukta seçilir. [pageCount] 0 veya altıysa [paginate]'e düşer.
  static List<TextPage> paginateInto(String text, int pageCount) {
    if (pageCount <= 0) return paginate(text);
    final length = text.length;
    final first = _skipWhitespace(text, 0);
    final average = (length - first) / pageCount;
    final window = (average * 0.3).round();
    final starts = <int>[first];
    for (var i = 1; i < pageCount; i++) {
      final ideal = first + (average * i).round();
      final cut = _skipWhitespace(text, _nearestBreak(text, ideal, window));
      starts.add(cut.clamp((starts.last + 1).clamp(0, length), length));
    }
    return [
      for (var i = 0; i < pageCount; i++)
        TextPage(
          start: starts[i],
          text: text.substring(starts[i], i + 1 < pageCount ? starts[i + 1] : length).trim(),
        ),
    ];
  }

  /// [ideal] konumuna en yakın ayırıcının bitişi; önce paragraf, sonra satır,
  /// cümle ve boşluk denenir. [window] içinde hiçbiri yoksa [ideal] döner.
  static int _nearestBreak(String text, int ideal, int window) {
    final lo = (ideal - window).clamp(0, text.length);
    final hi = (ideal + window).clamp(0, text.length);
    final slice = text.substring(lo, hi);
    final center = ideal - lo;
    for (final separator in ['\n\n', '\n', '. ', ' ']) {
      final before = slice.lastIndexOf(separator, (center - separator.length).clamp(0, slice.length));
      final after = slice.indexOf(separator, center.clamp(0, slice.length));
      final candidates = [
        if (before >= 0) before + separator.length,
        if (after >= 0) after + separator.length,
      ];
      if (candidates.isEmpty) continue;
      candidates.sort((a, b) => (a - center).abs().compareTo((b - center).abs()));
      return lo + candidates.first;
    }
    return ideal.clamp(0, text.length);
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
}
