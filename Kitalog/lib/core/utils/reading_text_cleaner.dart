/// Okuma metnini kitabın asıl içeriğine indirger: Gutenberg biçim işaretleri,
/// görsel/dipnot/transkripsiyon notları ve kitap başındaki başlık sayfası ile
/// içindekiler listesi temizlenir. Kurallar kitaba özel değil, geneldir; bu
/// yüzden ileride eklenecek kitaplarda da çalışır. Sezgisel bir kural metnin
/// büyük kısmını silmeye kalkarsa uygulanmaz (`_maxRemovedRatio`).
abstract final class ReadingTextCleaner {
  /// Kurallar değiştiğinde artırılır; eski sürümle temizlenmiş kopyalar
  /// açılırken yeniden temizlenir.
  static const int version = 1;

  static const double _maxRemovedRatio = 0.3;
  static const List<String> _subscripts = [
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉',
  ];

  // ---- Gutenberg biçim işaretleri ----------------------------------------

  /// Gutenberg düz metnine özgü işaretleri temizler. Satır yapısını korur
  /// (paragraf birleştirmeden önce de sonra da güvenle çalışır).
  static String cleanGutenbergMarkup(String text) {
    var t = text;
    // [Illustration], [Illustration: …], [Picture: …] (birden çok satır olabilir).
    t = t.replaceAll(
      RegExp(r'\[(Illustration|Picture)\b[^\]]*\]', caseSensitive: false),
      '',
    );
    t = t.replaceAll(
      RegExp(r'\[\s*Footnote\b[^\]]*\]', caseSensitive: false),
      '',
    );
    t = t.replaceAll(
      RegExp(
        r'''\[\s*(Original\s+)?Transcriber[’']?s?\s+notes?\b[^\]]*\]''',
        caseSensitive: false,
      ),
      '',
    );
    // Dipnot paragrafları ("[1] Açıklama…") ve metin içi dipnot numaraları.
    t = t.replaceAllMapped(
      RegExp(r'(^|\n\n)\s*\[\d{1,3}\][^\n]*(\n(?!\n)[^\n]*)*'),
      (m) => m.group(1)!,
    );
    t = t.replaceAll(RegExp(r' ?\[\d{1,3}\]'), '');
    // Alt simge: "C_{2}H" → "C₂H".
    t = t.replaceAllMapped(
      RegExp(r'_\{(\d+)\}'),
      (m) => m.group(1)!.split('').map((d) => _subscripts[int.parse(d)]).join(),
    );
    // Sayfa/dipnot işaretleri: "{356a}", "{4}".
    t = t.replaceAllMapped(
      RegExp(r' ?\{\d{1,4}[a-z]?\} ?'),
      (m) => m[0]!.startsWith(' ') && m[0]!.endsWith(' ') ? ' ' : '',
    );
    // _italik_ ve =kalın= (paragraf içinde satır atlayabilir). Kelime içindeki
    // italikler ("_Un_important", "1_st_") ve eşleşmeyen tek alt çizgiler de
    // kaldırılır; Gutenberg düz metninde alt çizgi yalnızca italik işaretidir.
    // "_____" gibi boşluk doldurma çizgileri korunur.
    t = t.replaceAllMapped(
      RegExp(r'(?<![\w_])_((?:[^_\n]|\n(?!\n))+?)_(?![\w_])'),
      (m) => m.group(1)!,
    );
    t = t.replaceAll(RegExp(r'(?<!_)_(?!_)'), '');
    t = t.replaceAllMapped(
      RegExp(r'(?<![\w=])=([^\s=](?:[^=\n]{0,58}[^\s=])?)=(?![\w=])'),
      (m) => m.group(1)!,
    );
    // "*       *       *" sahne ayracı sadeleştirilir.
    t = t.replaceAll(
      RegExp(r'^[ \t]*(\*[ \t]*){3,}$', multiLine: true),
      '* * *',
    );
    t = _removeTranscriberSections(t);
    return _tidy(t);
  }

  /// "TRANSCRIBER'S NOTE" başlığı ve onu izleyen düzyazı paragrafları silinir.
  static String _removeTranscriberSections(String text) {
    final paras = _paragraphs(text);
    final heading = RegExp(
      r'''^(original\s+)?transcriber[’']?s?\s+notes?:?\.?$''',
      caseSensitive: false,
    );
    final out = <String>[];
    var skipping = false;
    for (final p in paras) {
      if (heading.hasMatch(p.trim())) {
        skipping = true;
        continue;
      }
      if (skipping && _isProse(p)) continue;
      skipping = false;
      out.add(p);
    }
    return out.join('\n\n');
  }

  // ---- Kitap başı (tüm kaynaklar) ------------------------------------------

  static final RegExp _meta = RegExp(
    r'(project gutenberg|gutenberg|e-?text|e-?book|transcriber|produced by|prepared by|'
    r'online edition|electronic edition|distributed proofread|html version|filenumbers|'
    r'italics? (text )?(are|is|has been) (represented|marked)|is represented as|'
    r'millennium fulcrum|note from the original file)',
    caseSensitive: false,
  );
  static final RegExp _contentsHeading = RegExp(
    r'^(table of )?contents\b[^\n]{0,30}$|^içindekiler\b[^\n]{0,30}$',
    caseSensitive: false,
  );
  static final RegExp _headingLike = RegExp(
    r'^(chapter|part|book|letter|section|preface|introduction|prologue|epilogue|foreword|'
    r'bölüm|kısım|önsöz|giriş|[ivxlcdm]+[.\s]|\d+[.\s])',
    caseSensitive: false,
  );

  /// Kitap başındaki transkripsiyon notlarını, başlık sayfasını ve içindekiler
  /// listesini atar; metin asıl içerikle (ilk bölüm başlığıyla) başlar.
  static String stripFrontMatter(String text) {
    final paras = _paragraphs(text);
    if (paras.length < 5) return text;
    final front = paras.take(25).toList();
    var cleaned = [
      for (var i = 0; i < paras.length; i++)
        if (i >= front.length || !_isMetaNote(paras[i])) paras[i],
    ];
    final afterContents = _bodyStartAfterContents(cleaned);
    if (afterContents != null) {
      cleaned = cleaned.sublist(afterContents);
    } else {
      cleaned = cleaned.sublist(_titleBlockEnd(cleaned));
    }
    final result = cleaned.join('\n\n');
    // Güvenlik: kural metnin büyük kısmını siliyorsa yanlış çalışıyordur.
    final originalLength = paras.join('\n\n').length;
    if (result.length < originalLength * (1 - _maxRemovedRatio)) return text;
    return result;
  }

  /// İçindekiler listesi varsa gövdenin başladığı paragrafın sırası: listenin ilk
  /// girdilerinden biri gövdede tekrar göründüğünde ve ardından düzyazı geldiğinde
  /// oradan başlanır. Eşleşme bulunamazsa yalnızca içindekiler bloğu atlanır.
  static int? _bodyStartAfterContents(List<String> paras) {
    final limit = (paras.length * 0.3).ceil().clamp(0, 120);
    var heading = -1;
    for (var i = 0; i < limit; i++) {
      if (_contentsHeading.hasMatch(paras[i].trim())) {
        heading = i;
        break;
      }
    }
    if (heading < 0) return null;
    // İçindekiler bloğu başlıktan sonraki liste paragraflarıdır (araya giren
    // "List of Illustrations" gibi alt listeler dahil). Gövde, listenin ilk
    // girdilerinden biri tekrar görünüp ardından düzyazı geldiğinde başlar; bu
    // kontrol blok içinde de yapılır, çünkü ilk bölüm başlığı ve altındaki kısa
    // satırlar (ör. "To Mrs. Saville") da liste gibi görünür.
    final entries = <String>[];
    var blockOpen = true;
    final end = (heading + 400).clamp(0, paras.length);
    int? blockEnd;
    for (var i = heading + 1; i < end; i++) {
      final p = paras[i];
      if (entries.isNotEmpty) {
        final key = _paragraphKey(p);
        final candidates = entries.take(3);
        if (key != null &&
            candidates.any((c) => _sameHeading(c, key)) &&
            _proseFollows(paras, i) &&
            !_listContinues(paras, i, entries, key)) {
          // "I" + "THE WORLD IN SPACE" gibi iki paragrafa bölünmüş başlıkta numara da korunur.
          return (i > heading + 1 && _isNumbering(paras[i - 1])) ? i - 1 : i;
        }
      }
      if (blockOpen && _isProse(p)) {
        blockOpen = false;
        blockEnd = i;
      }
      if (blockOpen) {
        for (final line in p.split('\n').expand((l) => l.split(_entrySplit))) {
          final key = _headingKey(line);
          if (key.length >= 3 && !_columnLabels.contains(key)) entries.add(key);
        }
      } else if (i - blockEnd! > 60) {
        break;
      }
    }
    return blockEnd ?? heading + 1;
  }

  /// Kısa paragrafın (en fazla 3 satır) başlık anahtarı; uzun paragraf başlık değildir.
  static String? _paragraphKey(String paragraph) {
    final lines = paragraph.trim().split('\n');
    final joined = lines.join(' ');
    if (lines.length > 3 || joined.length > 120) return null;
    final key = _headingKey(joined);
    return key.length >= 3 ? key : null;
  }

  /// Kısa transkripsiyon/yayın notu; içinde "Gutenberg" geçen başlık ya da
  /// içindekiler listesi (ör. "Preface to the Project Gutenberg Etext") korunur.
  static bool _isMetaNote(String paragraph) =>
      _meta.hasMatch(paragraph) &&
      !_isHeadingLike(paragraph) &&
      '\n'.allMatches(paragraph).length < 6;

  /// İçindekiler sütun başlıkları ("PAGE") girdi sayılmaz.
  static const Set<String> _columnLabels = {'page', 'pages', 'sayfa'};

  /// Ayrıntılı içindekilerde her girdinin altında özet paragrafı bulunur; eşleşen
  /// başlıktan kısa süre sonra başka bir girdi geliyorsa liste sürüyordur.
  static bool _listContinues(
    List<String> paras,
    int from,
    List<String> entries,
    String key,
  ) {
    for (var i = from + 1; i < paras.length && i <= from + 2; i++) {
      final next = _paragraphKey(paras[i]);
      if (next != null &&
          !_sameHeading(next, key) &&
          entries.any((e) => _sameHeading(e, next))) {
        return true;
      }
    }
    return false;
  }

  static bool _sameHeading(String a, String b) =>
      a == b || a.startsWith('$b ') || b.startsWith('$a ');

  static bool _isNumbering(String paragraph) => RegExp(
    r'^((chapter|part|book|bölüm)\s+)?([ivxlcdm]+|\d+)\.?$',
    caseSensitive: false,
  ).hasMatch(paragraph.trim());

  /// İçindekiler yoksa: baştaki başlık sayfası (en az 3 kısa paragraf: ad,
  /// yazar, yayınevi, yıl) atılır; ilk bölüm başlıkları korunur. Şiir dizeleri,
  /// cümleler ve uzun paragraflar başlık sayfası sayılmaz.
  static int _titleBlockEnd(List<String> paras) {
    var end = 0;
    while (end < paras.length && end < 30 && _isTitleLine(paras[end])) {
      end++;
    }
    if (end < 3 || end >= paras.length) return 0;
    for (final back in [2, 1]) {
      final i = end - back;
      if (i >= 0 && _isHeadingLike(paras[i])) return i;
    }
    return end;
  }

  static bool _isTitleLine(String paragraph) {
    final lines = paragraph.split('\n').map((l) => l.trim()).toList();
    if (lines.length > 6 || lines.any((l) => l.length > 90)) return false;
    return !_isSentence(paragraph);
  }

  /// En az 8 kelimelik, noktalama ile biten ve tamamı büyük harf olmayan
  /// paragraf (ör. Nutuk'un ilk cümlesi; "CHISWICK PRESS…" künyesi değil).
  static bool _isSentence(String paragraph) {
    final text = paragraph.replaceAll('\n', ' ').trim();
    return text.split(RegExp(r'\s+')).length >= 8 &&
        RegExp(r'[.:!?…”"’]$').hasMatch(text) &&
        text != text.toUpperCase();
  }

  static bool _proseFollows(List<String> paras, int from) {
    for (var i = from; i < paras.length && i <= from + 4; i++) {
      if (_isProse(paras[i])) return true;
    }
    return false;
  }

  static final RegExp _chapterMarker = RegExp(
    r'\b(chapter|letter|book|part|bölüm)\s+([ivxlcdm]+|\d+)\b',
    caseSensitive: false,
  );
  static final RegExp _entrySplit = RegExp(
    r'(?=\b(?:chapter|letter|book|part|bölüm)\s+(?:[ivxlcdm]+|\d+)\b)|(?<=\s(?:\d{1,3}|[ivxlc]{1,6}))\s+(?=[A-Z])',
    caseSensitive: false,
  );

  /// Tek satıra birleştirilmiş liste: çok sayıda bölüm numarası ya da sayfa
  /// numarası içeren veya tamamı büyük harf olan satır (eski kopyalarda görülür).
  static bool _isJoinedList(String line) =>
      _chapterMarker.allMatches(line).length >= 3 ||
      RegExp(r'\s\d{1,3}\s+[A-Z]').allMatches(line).length >= 4 ||
      line == line.toUpperCase();

  static final RegExp _listLine = RegExp(
    r'^(chapter|part|book|letter|section|bölüm|kısım|[ivxlcdm]+\.|\d+\.)\s|\s\d+\s*$',
    caseSensitive: false,
  );

  /// Düzyazı: satıra bölünmüş metinde en az iki uzun satır, tek satırlık
  /// paragrafta (EPUB, Vikikaynak, birleştirilmiş metin) uzun tek satır.
  /// Satırlarının çoğu bölüm/numara ile başlayan ya da sayfa numarasıyla biten
  /// paragraf (içindekiler, görsel listesi) düzyazı sayılmaz.
  static bool _isProse(String paragraph) {
    final lines = paragraph
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return false;
    final listLines = lines
        .where((l) => l.length <= 50 || _listLine.hasMatch(l))
        .length;
    if (lines.length > 1 && listLines / lines.length >= 0.6) return false;
    if (lines.length == 1) {
      final line = lines.first;
      return line.length > 120 &&
          !_listLine.hasMatch(line) &&
          !_isJoinedList(line);
    }
    return lines.where((l) => l.length > 50).length >= 2;
  }

  static bool _isHeadingLike(String paragraph) {
    final p = paragraph.trim();
    return p.length < 80 && !p.contains('\n') && _headingLike.hasMatch(p);
  }

  /// Başlık karşılaştırma anahtarı: küçük harf, noktalama ve sondaki sayfa numarası
  /// atılır; baştaki numaralandırma ("I.", "Chapter 1", "Part II") yok sayılır.
  static String _headingKey(String line) {
    var key = line
        .toLowerCase()
        .replaceAll(RegExp(r'\s+\d+\s*$'), '')
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .trim();
    key = key.replaceFirst(
      RegExp(r'^((chapter|part|book|letter|bölüm)\s+)?([ivxlcdm]+|\d+)\s+'),
      '',
    );
    return key;
  }

  static List<String> _paragraphs(String text) => text
      .replaceAll('\r\n', '\n')
      .split(RegExp(r'\n[ \t]*\n'))
      .map((p) => p.replaceAll(RegExp(r'^\n+|\n+$'), ''))
      .where((p) => p.trim().isNotEmpty)
      .toList();

  static String _tidy(String text) => text
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
