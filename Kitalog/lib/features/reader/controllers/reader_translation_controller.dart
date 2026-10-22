import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/repositories/digital_book_repository.dart';
import '../../../core/repositories/translation/translation_engine.dart';
import '../../../core/repositories/translation_repository.dart';
import '../models/reader_model.dart';
import '../models/reader_translation_model.dart';
import 'reader_controller.dart';

/// Okuyucudaki İngilizce ↔ Türkçe çeviri: metin sayfasını (orijinal / çeviri /
/// alt alta) ve seçilen metni çevirir. Okuyucunun durumunu dinler; sayfa
/// değişince yeni sayfa (ve kaydırmada beklememek için bir sonraki) çevrilir.
/// Dili bilinmeyen kitapta (yüklenen eski dosyalar) dil metinden tanınıp
/// kitaba kaydedilir. Dil paketi eksikse çeviriden önce onay istenir (iOS'ta
/// onayı sistem kendi penceresinde sorar).
class ReaderTranslationController {
  ReaderTranslationController({
    required this._library,
    required this._digital,
    required this._translation,
    required this._reader,
    required this.bookId,
  });

  final LibraryController _library;
  final DigitalBookRepository _digital;
  final TranslationRepository _translation;
  final ValueListenable<ReaderModel> _reader;
  final String bookId;

  final ValueNotifier<ReaderTranslationModel> state =
      ValueNotifier<ReaderTranslationModel>(const ReaderTranslationModel());

  /// Dil paketi onayı sonrası yapılacak iş (sayfa veya seçim çevirisi).
  Future<void> Function()? _pending;
  final Set<int> _inFlight = {};
  bool _detectionTried = false;
  bool _disposed = false;

  void init() {
    final edition = _library.bookById(bookId)?.digitalEdition;
    state.value = state.value.copyWith(
      isSupported: _translation.isSupported,
      sourceLanguage: edition?.languageCode ?? '',
    );
    _reader.addListener(_onReaderChanged);
    _onReaderChanged();
  }

  int get _pageIndex => _reader.value.pageIndex;

  void _onReaderChanged() {
    final reader = _reader.value;
    if (reader.status != ReaderStatus.ready || !state.value.isSupported) return;
    if (state.value.sourceLanguage.isEmpty && !_detectionTried) {
      _detectionTried = true;
      unawaited(_detectLanguage());
    }
    final current = state.value;
    if (current.showsTranslation &&
        !current.modelPromptPending &&
        current.status != TranslationStatus.downloadingModel) {
      unawaited(_translateAround(reader.pageIndex));
    }
  }

  /// Kitabın dili metinden tanınır ve kitaba yazılır (bir dahaki açılışta yeniden tanınmaz).
  Future<void> _detectLanguage() async {
    final language = await _translation.detectLanguage(
      await _digital.sampleText(bookId),
    );
    if (_disposed || language.isEmpty) return;
    final book = _library.bookById(bookId);
    final edition = book?.digitalEdition;
    if (book != null && edition != null) {
      await _library.updateBook(
        book.copyWith(digitalEdition: edition.copyWith(languageCode: language)),
      );
    }
    if (!_disposed) {
      state.value = state.value.copyWith(sourceLanguage: language);
    }
  }

  /// Metin sayfasının görünümünü değiştirir; çeviri gerekiyorsa sayfa çevrilir.
  Future<void> setView(TranslationView view) async {
    final current = state.value;
    if (view == TranslationView.original) {
      state.value = current.copyWith(
        view: view,
        status: TranslationStatus.idle,
        clearFailure: true,
      );
      return;
    }
    if (!current.isAvailable) return;
    state.value = current.copyWith(view: view, clearFailure: true);
    await _withModels(() => _translateAround(_pageIndex));
  }

  /// Seçilen metni çevirir; sonuç [ReaderTranslationModel.selection]'da.
  Future<void> translateSelection(
    String text,
    int pageNumber, {
    bool reflow = false,
  }) async {
    if (!state.value.isAvailable) return;
    final normalized = ReaderController.normalizeQuote(text, reflow: reflow);
    if (normalized.isEmpty) return;
    state.value = state.value.copyWith(
      selection: SelectionTranslation(
        text: normalized,
        pageNumber: pageNumber,
        reflow: reflow,
      ),
    );
    await _withModels(_translateSelection);
  }

  /// Seçim çevirisi başarısızsa yeniden dener (dil paketi eksikse önce indirir).
  Future<void> retrySelection() async {
    final selection = state.value.selection;
    if (selection == null) return;
    final failure = selection.failure;
    state.value = state.value.copyWith(
      selection: SelectionTranslation(
        text: selection.text,
        pageNumber: selection.pageNumber,
        reflow: selection.reflow,
      ),
    );
    if (failure == TranslationFailure.modelDownload) {
      await _download(_translateSelection);
    } else {
      await _translateSelection();
    }
  }

  void clearSelection() {
    if (_disposed) return;
    state.value = state.value.copyWith(clearSelection: true);
  }

  /// Dil paketi onayının sonucu. Reddedilirse görünüm orijinale döner.
  Future<void> confirmModelDownload(bool accepted) async {
    final action = _pending;
    _pending = null;
    state.value = state.value.copyWith(modelPromptPending: false);
    if (!accepted) {
      _declineDownload();
      return;
    }
    await _download(action);
  }

  /// Dil paketi reddedildi: görünüm orijinale döner, seçim penceresi kapanır.
  void _declineDownload() {
    state.value = state.value.copyWith(
      view: TranslationView.original,
      status: TranslationStatus.idle,
      clearFailure: true,
      clearSelection: true,
    );
  }

  /// Hata sonrası yeniden dener (dil paketi indirilemediyse onay sormadan indirir).
  Future<void> retry() async {
    final current = state.value;
    if (current.failure == TranslationFailure.modelDownload) {
      await _download(() => _translateAround(_pageIndex));
      return;
    }
    state.value = current.copyWith(
      status: TranslationStatus.idle,
      clearFailure: true,
    );
    await _translateAround(_pageIndex);
  }

  Future<void> _withModels(Future<void> Function() action) async {
    final target = state.value.targetLanguage;
    if (target == null) return;
    if (await _translation.needsModelDownload(
      state.value.sourceLanguage,
      target,
    )) {
      if (_translation.systemConfirmsDownload) {
        await _download(action);
        return;
      }
      _pending = action;
      if (!_disposed) {
        state.value = state.value.copyWith(modelPromptPending: true);
      }
      return;
    }
    await action();
  }

  Future<void> _download(Future<void> Function()? action) async {
    final target = state.value.targetLanguage;
    if (target == null) return;
    state.value = state.value.copyWith(
      status: TranslationStatus.downloadingModel,
      clearFailure: true,
    );
    try {
      await _translation.downloadModels(state.value.sourceLanguage, target);
    } on TranslationException catch (e) {
      if (_disposed) return;
      // iOS'ta kullanıcı sistem penceresinde vazgeçti: uygulamadaki "reddet" gibi davranılır.
      if (e.failure == TranslationFailure.downloadDeclined) {
        _declineDownload();
        return;
      }
      final selection = state.value.selection;
      state.value = state.value.copyWith(
        status: TranslationStatus.failure,
        failure: e.failure,
        selection: selection?.copyWith(isLoading: false, failure: e.failure),
      );
      return;
    }
    if (_disposed) return;
    state.value = state.value.copyWith(status: TranslationStatus.idle);
    await action?.call();
  }

  /// Gösterilen sayfa çevrilir; ardından bir sonraki sayfa sessizce hazırlanır.
  Future<void> _translateAround(int index) async {
    await _translatePage(index);
    if (!_disposed && state.value.failure == null) {
      await _translatePage(index + 1, quiet: true);
    }
  }

  Future<void> _translatePage(int index, {bool quiet = false}) async {
    final pages = _reader.value.pages;
    final target = state.value.targetLanguage;
    if (target == null || index < 0 || index >= pages.length) return;
    if (state.value.pages.containsKey(index) || !_inFlight.add(index)) return;
    if (!quiet) {
      state.value = state.value.copyWith(
        status: TranslationStatus.translating,
        clearFailure: true,
      );
    }
    try {
      final lines = await _translation.translateLines(
        bookId,
        pages[index].text.split('\n'),
        from: state.value.sourceLanguage,
        to: target,
      );
      if (_disposed) return;
      state.value = state.value.copyWith(
        pages: {...state.value.pages, index: lines},
      );
      if (!quiet) {
        state.value = state.value.copyWith(status: TranslationStatus.idle);
      }
    } on TranslationException catch (e) {
      if (!quiet && !_disposed) {
        state.value = state.value.copyWith(
          status: TranslationStatus.failure,
          failure: e.failure,
        );
      }
    } finally {
      _inFlight.remove(index);
    }
  }

  Future<void> _translateSelection() async {
    final selection = state.value.selection;
    final target = state.value.targetLanguage;
    if (selection == null || target == null) return;
    SelectionTranslation result;
    try {
      final translated = await _translation.translateText(
        bookId,
        selection.text,
        from: state.value.sourceLanguage,
        to: target,
      );
      result = selection.copyWith(translated: translated, isLoading: false);
    } on TranslationException catch (e) {
      result = selection.copyWith(isLoading: false, failure: e.failure);
    }
    // Pencere bu arada kapatıldıysa veya başka bir seçim çevrildiyse sonuç atılır.
    if (_disposed || !identical(state.value.selection, selection)) return;
    state.value = state.value.copyWith(selection: result);
  }

  void dispose() {
    _disposed = true;
    _reader.removeListener(_onReaderChanged);
    state.dispose();
  }
}
