import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/repositories/digital_book_repository.dart';
import '../../../core/repositories/digital_sources/source_http.dart';
import '../models/digital_edition_actions.dart';
import '../models/digital_edition_state.dart';
import 'book_file_picker.dart';

/// Kitap Detay'daki dijital sürüm bölümü: telifi bitmiş kitapların indirilmesi,
/// kullanıcının kendi PDF / EPUB dosyasının yüklenmesi ve cihazdan silme.
class DigitalEditionController {
  DigitalEditionController({
    required this._library,
    required this._digital,
    required this._picker,
    required this.bookId,
  });

  final LibraryController _library;
  final DigitalBookRepository _digital;
  final BookFilePicker _picker;
  final String bookId;

  final ValueNotifier<DigitalEditionState> state =
      ValueNotifier<DigitalEditionState>(const DigitalEditionState());

  late final DigitalEditionActions actions = DigitalEditionActions(
    download: download,
    deleteCopy: deleteCopy,
    importFile: importFile,
  );

  /// Cihazdaki kopyayı (ve okuyucuda değişen kalınan yeri) yeniden okur.
  Future<void> load() async {
    final copy = await _digital.copyOf(bookId);
    state.value = state.value.copyWith(copy: copy, clearCopy: copy == null);
  }

  Future<void> download() async {
    final book = _library.bookById(bookId);
    if (book == null || state.value.isBusy) return;
    state.value = state.value.copyWith(isDownloading: true, progress: 0, clearError: true);
    try {
      final copy = await _digital.download(
        book,
        onProgress: (p) => state.value = state.value.copyWith(progress: p),
      );
      state.value = state.value.copyWith(copy: copy, isDownloading: false);
    } on DigitalBookException catch (e) {
      state.value = state.value.copyWith(isDownloading: false, error: e.failure);
    }
  }

  /// Seçilen PDF / EPUB kitaba bağlanır; önceki dosya varsa yerine geçer.
  Future<void> importFile() async {
    if (state.value.isBusy) return;
    final picked = await _picker.pick();
    final book = _library.bookById(bookId);
    if (picked == null || book == null) return;
    state.value = state.value.copyWith(isImporting: true, clearError: true);
    try {
      final result = await _digital.importFile(book, fileName: picked.name, bytes: picked.bytes);
      await _library.updateBook(book.copyWith(digitalEdition: result.edition));
      state.value = DigitalEditionState(copy: result.copy);
    } on DigitalBookException catch (e) {
      state.value = state.value.copyWith(isImporting: false, error: e.failure);
    }
  }

  /// Cihazdaki kopyayı siler. Kullanıcı dosyası yeniden indirilemeyeceği için
  /// kitabın dosya bağlantısı da kaldırılır (bölüm yeniden "Dosya yükle"ye döner).
  Future<void> deleteCopy() async {
    await _digital.delete(bookId);
    final book = _library.bookById(bookId);
    if (book != null && (book.digitalEdition?.isLocalFile ?? false)) {
      await _library.updateBook(book.copyWith(clearDigitalEdition: true));
    }
    state.value = const DigitalEditionState();
  }

  void dispose() {
    state.dispose();
  }
}
