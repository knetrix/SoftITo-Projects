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
  final int pageChars;
  int _textLength = 0;

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
      state.value = ReaderModel(
        status: ReaderStatus.ready,
        format: DigitalFormat.pdf,
        pdfBytes: bytes,
        pdfPageCount: copy!.charCount,
        pageIndex: copy.lastOffset,
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

  /// PDF görüntüleyici belgeyi açınca sayfa sayısı kaydedilir.
  Future<void> pdfReady(int pageCount) async {
    if (pageCount <= 0) return;
    state.value = state.value.copyWith(pdfPageCount: pageCount);
    await _digital.updateLength(bookId, pageCount);
  }

  /// PDF'te sayfa değişti (1'den başlayan numara): kalınan yer ve sayfa sayacı güncellenir.
  Future<void> pdfPageChanged(int pageNumber) async {
    final total = state.value.pdfPageCount;
    if (!state.value.isPdf || total <= 0) return;
    final index = (pageNumber - 1).clamp(0, total - 1);
    state.value = state.value.copyWith(pageIndex: index);
    await _digital.savePosition(bookId, index);
    final progress = index >= total - 1 ? 1.0 : index / total;
    await _syncProgress(progress);
  }

  Future<void> _syncProgress(double progress) async {
    final printed = TextPaginator.printedPageFor(progress, book?.pageCount ?? 0);
    final reachedEnd = await _library.setCurrentPage(bookId, printed);
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
    _textLength = text.length;
    final pages = TextPaginator.paginate(text, targetChars: pageChars);
    final copy = await _digital.copyOf(bookId);
    var offset = copy?.lastOffset ?? 0;
    // İlk açılışta kitabın sayfa sayacındaki ilerlemeden başlanır.
    if (offset == 0 && current.currentPage > 0 && current.status != ReadingStatus.finished) {
      offset = (current.progress * text.length).round();
    }
    state.value = ReaderModel(
      status: ReaderStatus.ready,
      pages: pages,
      pageIndex: TextPaginator.pageIndexForOffset(pages, offset),
      downloadProgress: 1,
    );
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
    final progress = target >= current.pages.length - 1
        ? 1.0
        : current.pages[target].start / (_textLength == 0 ? 1 : _textLength);
    await _syncProgress(progress);
  }

  Future<void> nextPage() => goToPage(state.value.pageIndex + 1);

  Future<void> previousPage() => goToPage(state.value.pageIndex - 1);

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
