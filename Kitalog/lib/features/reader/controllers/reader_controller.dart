import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/digital_format.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/repositories/digital_book_repository.dart';
import '../../../core/repositories/digital_sources/source_http.dart';
import '../../../core/utils/text_paginator.dart';
import '../models/reader_model.dart';

/// Dijital okuyucu: metni cihazdan açar (yoksa indirir), sayfalar ve okuma
/// konumunu hem dijital kopyaya hem de kitabın sayfa sayacına yansıtır.
/// Okuyucunun sayfa sayısı her zaman kitabın sayfa sayısına eşittir: metin
/// kitabın sayfa sayısı kadar sayfaya bölünür; PDF'te, sayfa sayısı bilinmeyen
/// kitapta ve bu sayıya bölünemeyecek kadar kısa metinde ise kitabın sayfa
/// sayısı okuyucunun sayfalarına eşitlenir.
/// Böylece okuyucudaki "Sayfa N" ile sayaçtaki N birebir aynıdır.
class ReaderController {
  ReaderController({
    required this._library,
    required this._digital,
    required this.bookId,
    this.pageChars = TextPaginator.defaultPageChars,
  });

  final LibraryController _library;
  final DigitalBookRepository _digital;
  final String bookId;

  /// Kitabın sayfa sayısına bölünemeyen metinde kullanılan sayfa uzunluğu.
  final int pageChars;

  final ValueNotifier<ReaderModel> state = ValueNotifier<ReaderModel>(
    const ReaderModel(),
  );

  BookModel? get book => _library.bookById(bookId);

  bool get supportsOffline => _digital.supportsOffline;

  Future<void> open() async {
    final current = book;
    if (current == null || !current.hasDigitalEdition) {
      _fail(DigitalBookFailure.unavailable);
      return;
    }
    final copy = await _digital.copyOf(bookId);
    if (copy?.format == DigitalFormat.pdf) {
      final bytes = await _digital.readPdf(bookId);
      if (bytes == null) return _fail(DigitalBookFailure.fileMissing);
      final total = copy!.charCount;
      await _library.alignPageCount(bookId, total);
      state.value = ReaderModel(
        status: ReaderStatus.ready,
        format: DigitalFormat.pdf,
        pdfBytes: bytes,
        pdfPageCount: total,
        // Sayfa sayısı henüz bilinmiyorsa okunan kitap PDF'te kalınan yerden açılır.
        pageIndex: total > 0 ? _startIndex(total) : (_isReading ? copy.lastOffset : 0),
      );
      return;
    }
    final text = await _digital.readText(bookId, book: current);
    if (text == null) {
      // Kullanıcının kendi dosyası indirilemez; cihazda yoksa yeniden yüklenmeli.
      state.value = current.digitalEdition!.isLocalFile
          ? const ReaderModel(status: ReaderStatus.failure, error: DigitalBookFailure.fileMissing)
          : const ReaderModel(status: ReaderStatus.notDownloaded);
      return;
    }
    await _showText(current, text);
  }

  /// PDF görüntüleyici belgeyi açınca sayfa sayısı kaydedilir ve kitabın
  /// sayfa sayısı PDF'inkine eşitlenir.
  Future<void> pdfReady(int pageCount) async {
    if (pageCount <= 0) return;
    state.value = state.value.copyWith(pdfPageCount: pageCount);
    await _digital.updateLength(bookId, pageCount);
    await _library.alignPageCount(bookId, pageCount);
  }

  /// PDF'te sayfa değişti (1'den başlayan numara): kalınan yer ve sayfa sayacı güncellenir.
  Future<void> pdfPageChanged(int pageNumber) async {
    final total = state.value.pdfPageCount;
    if (!state.value.isPdf || total <= 0) return;
    final index = (pageNumber - 1).clamp(0, total - 1);
    state.value = state.value.copyWith(pageIndex: index);
    await _digital.savePosition(bookId, index);
    await _syncPage(index + 1);
  }

  /// Ekrandaki sayfa numarası (1'den başlar) doğrudan sayfa sayacına yazılır.
  Future<void> _syncPage(int pageNumber) async {
    final reachedEnd = await _library.setCurrentPage(bookId, pageNumber);
    if (reachedEnd) {
      state.value = state.value.copyWith(finishSuggested: true);
    }
  }

  Future<void> download() async {
    final current = book;
    if (current == null || state.value.status == ReaderStatus.downloading) return;
    state.value = const ReaderModel(status: ReaderStatus.downloading);
    try {
      await _digital.download(
        current,
        onProgress: (p) => state.value = state.value.copyWith(downloadProgress: p),
      );
      final text = await _digital.readText(bookId);
      if (text == null) return _fail(DigitalBookFailure.storage);
      await _showText(current, text);
    } on DigitalBookException catch (e) {
      _fail(e.failure);
    }
  }

  Future<void> _showText(BookModel current, String text) async {
    final List<TextPage> pages;
    if (TextPaginator.fitsPageCount(text, current.pageCount)) {
      pages = TextPaginator.paginateInto(text, current.pageCount);
    } else {
      pages = TextPaginator.paginate(text, targetChars: pageChars);
      await _library.alignPageCount(bookId, pages.length);
    }
    state.value = ReaderModel(
      status: ReaderStatus.ready,
      pages: pages,
      pageIndex: _startIndex(pages.length),
      downloadProgress: 1,
    );
  }

  bool get _isReading => book?.status == ReadingStatus.reading;

  /// Açılış sayfası: okunan kitapta sayfa sayacı tek doğruluk kaynağıdır
  /// (sayaçta N ise okuyucu N. sayfada açılır). Okunacak (hiç başlanmamış) ve
  /// biten kitap her zaman ilk sayfadan açılır.
  int _startIndex(int total) {
    final current = book;
    if (current == null || !_isReading || total <= 0) return 0;
    return (current.currentPage - 1).clamp(0, total - 1);
  }

  /// Sayfaya gider; kalınan yeri kaydeder ve kitabın sayfa sayacını günceller.
  Future<void> goToPage(int index) async {
    final current = state.value;
    if (current.status != ReaderStatus.ready || current.isPdf || current.pages.isEmpty) return;
    final target = index.clamp(0, current.pages.length - 1);
    if (target != current.pageIndex) {
      state.value = current.copyWith(pageIndex: target);
    }
    await _digital.savePosition(bookId, current.pages[target].start);
    await _syncPage(target + 1);
  }

  Future<void> nextPage() => goToPage(state.value.pageIndex + 1);

  Future<void> previousPage() => goToPage(state.value.pageIndex - 1);

  /// Okuyucuda seçilen metni [pageNumber]. sayfanın alıntısı olarak kaydeder.
  /// Alıntılar paylaşılan listede tutulduğu için Kitap Detay'daki Alıntılar
  /// bölümü anında güncellenir. Aynı sayfadaki aynı metin ikinci kez eklenmez.
  /// PDF'te satır sonları seçimin parçası olduğu için ([reflow]) birleştirilir.
  Future<void> saveQuote(String selected, int pageNumber, {bool reflow = false}) async {
    final text = normalizeQuote(selected, reflow: reflow);
    if (text.isEmpty) return;
    final exists = _library.quotesOf(bookId).any((q) => q.text == text && q.page == pageNumber);
    if (!exists) await _library.addQuote(bookId, text, pageNumber);
    state.value = state.value.copyWith(
      quoteResult: exists ? QuoteSaveResult.duplicate : QuoteSaveResult.saved,
    );
  }

  void consumeQuoteResult() {
    state.value = state.value.copyWith(clearQuoteResult: true);
  }

  /// Seçimdeki fazla boşlukları temizler. Metinde satır ve paragraf yapısı
  /// (ör. şiir) korunur; [reflow] ise satır sonunda bölünmüş kelimeler
  /// birleştirilip tüm satırlar tek paragrafa çevrilir.
  static String normalizeQuote(String selected, {bool reflow = false}) {
    var text = selected.replaceAll('\r', '');
    if (reflow) {
      text = text.replaceAllMapped(RegExp(r'(\p{L})-\n(?=\p{Ll})', unicode: true), (m) => m[1]!);
      return text.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return text
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  void consumeFinishSuggestion() {
    state.value = state.value.copyWith(finishSuggested: false);
  }

  Future<void> markFinished() => _library.setStatus(bookId, ReadingStatus.finished);

  void _fail(DigitalBookFailure failure) {
    state.value = ReaderModel(status: ReaderStatus.failure, error: failure);
  }

  void dispose() {
    state.dispose();
  }
}
