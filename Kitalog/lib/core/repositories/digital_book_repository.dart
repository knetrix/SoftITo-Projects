import 'dart:convert';
import 'dart:typed_data';

import '../constants/storage_keys.dart';
import '../data/bundled_texts.dart';
import '../models/book_genre.dart';
import '../models/book_model.dart';
import '../models/digital_copy_model.dart';
import '../models/digital_edition_model.dart';
import '../models/digital_format.dart';
import '../models/digital_source.dart';
import '../storage/digital_file_storage.dart';
import '../storage/local_storage_service.dart';
import '../utils/epub_text_extractor.dart';
import '../utils/reading_text_cleaner.dart';
import '../utils/text_cleaner.dart';
import 'digital_sources/gutenberg_source.dart';
import 'digital_sources/source_http.dart';
import 'digital_sources/wikisource_source.dart';

/// Dijital kitap metinlerini indirir, cihazda saklar ve kalınan yeri tutar.
/// İndirme bilgileri `kitalog.digital` anahtarında, metinler dosyada durur.
class DigitalBookRepository {
  DigitalBookRepository({
    required this._storage,
    required this._files,
    required this._gutenberg,
    required this._wikisource,
    required this._loadAsset,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LocalStorageService _storage;
  final DigitalFileStorage _files;
  final GutenbergSource _gutenberg;
  final WikisourceSource _wikisource;

  /// Paketlenmiş metni okur (uygulamada `rootBundle.loadString`).
  final Future<String> Function(String assetPath) _loadAsset;
  final DateTime Function() _clock;

  /// `false` ise (web) metin yalnızca oturum boyunca tutulur.
  bool get supportsOffline => _files.isPersistent;

  Future<List<DigitalCopyModel>> getCopies() async {
    return _storage
        .readJsonList(StorageKeys.digital)
        .map(DigitalCopyModel.fromJson)
        .where((c) => c.bookId.isNotEmpty)
        .toList();
  }

  Future<DigitalCopyModel?> copyOf(String bookId) async {
    for (final copy in await getCopies()) {
      if (copy.bookId == bookId) return copy;
    }
    return null;
  }

  /// Kitabın dijital metnini kaynağından indirip cihaza kaydeder.
  Future<DigitalCopyModel> download(
    BookModel book, {
    void Function(double progress)? onProgress,
  }) async {
    final edition = book.digitalEdition;
    if (edition == null) {
      throw const DigitalBookException(DigitalBookFailure.unavailable);
    }
    // Kullanıcının kendi dosyası yeniden indirilemez; yeniden yüklenmesi gerekir.
    if (edition.isLocalFile) {
      throw const DigitalBookException(DigitalBookFailure.fileMissing);
    }
    onProgress?.call(0.05);
    final text = _prepare(await _fetch(edition, onProgress), book.genre);
    final fileName = DigitalFileStorage.fileNameFor(book.id);
    try {
      await _files.write(fileName, text);
    } on Exception {
      throw const DigitalBookException(DigitalBookFailure.storage);
    }
    final previous = await copyOf(book.id);
    final copy = DigitalCopyModel(
      bookId: book.id,
      fileName: fileName,
      charCount: text.length,
      downloadedAt: _clock(),
      lastOffset: (previous?.lastOffset ?? 0).clamp(0, text.length),
      byteSize: utf8.encode(text).length,
      textVersion: ReadingTextCleaner.version,
    );
    await _saveCopy(copy);
    onProgress?.call(1);
    return copy;
  }

  /// Kitap başı (başlık sayfası, içindekiler, notlar) atılır. Şiirde satır
  /// sonları anlam taşır; düzyazıda satıra bölünmüş paragraflar birleştirilir.
  static String _prepare(String raw, BookGenre genre) {
    final text = ReadingTextCleaner.stripFrontMatter(raw);
    return genre == BookGenre.poetry
        ? text
        : TextCleaner.reflowParagraphs(text);
  }

  Future<String> _fetch(
    DigitalEditionModel edition,
    void Function(double)? onProgress,
  ) async {
    final asset = BundledTexts.assetFor(edition);
    if (asset != null) {
      try {
        return await _loadAsset(asset);
      } on Exception {
        // Paketlenmiş dosya okunamazsa kaynağından indirmeye düşülür.
      }
    }
    return switch (edition.source) {
      DigitalSource.gutenberg => _gutenberg.fetchText(edition.sourceId),
      DigitalSource.wikisource => _wikisource.fetchText(
        edition.sourceId,
        onProgress: onProgress,
      ),
      DigitalSource.localFile => throw const DigitalBookException(
        DigitalBookFailure.fileMissing,
      ),
    };
  }

  /// Yüklenebilecek en büyük kullanıcı dosyası.
  static const int maxImportBytes = 150 * 1024 * 1024;

  /// Kullanıcının seçtiği PDF / EPUB dosyasını kitaba bağlar ve cihaza kaydeder.
  /// EPUB metne çevrilip okuyucuda sayfalanır; PDF olduğu gibi saklanır.
  Future<({DigitalEditionModel edition, DigitalCopyModel copy})> importFile(
    BookModel book, {
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (bytes.length > maxImportBytes) {
      throw const DigitalBookException(DigitalBookFailure.tooLarge);
    }
    final format = detectFormat(fileName, bytes);
    final DigitalCopyModel copy;
    if (format == DigitalFormat.pdf) {
      copy = await _store(
        book.id,
        DigitalFormat.pdf,
        DigitalFileStorage.fileNameFor(book.id, extension: 'pdf'),
        (name) => _files.writeBytes(name, bytes),
        length: 0,
        byteSize: bytes.length,
      );
    } else {
      final text = _prepare(EpubTextExtractor.extract(bytes), book.genre);
      copy = await _store(
        book.id,
        DigitalFormat.text,
        DigitalFileStorage.fileNameFor(book.id),
        (name) => _files.write(name, text),
        length: text.length,
        byteSize: utf8.encode(text).length,
      );
    }
    final edition = DigitalEditionModel(
      source: DigitalSource.localFile,
      sourceId: fileName,
      languageCode: '',
      format: copy.format,
    );
    return (edition: edition, copy: copy);
  }

  Future<DigitalCopyModel> _store(
    String bookId,
    DigitalFormat format,
    String fileName,
    Future<void> Function(String fileName) write, {
    required int length,
    required int byteSize,
  }) async {
    // Önceki kopya (başka biçimde olabilir) temizlenir.
    await delete(bookId);
    try {
      await write(fileName);
    } on Exception {
      throw const DigitalBookException(DigitalBookFailure.storage);
    }
    final copy = DigitalCopyModel(
      bookId: bookId,
      fileName: fileName,
      charCount: length,
      downloadedAt: _clock(),
      format: format,
      byteSize: byteSize,
      textVersion: format == DigitalFormat.text
          ? ReadingTextCleaner.version
          : 0,
    );
    await _saveCopy(copy);
    return copy;
  }

  /// İçeriğe göre biçimi bulur: `%PDF` imzası PDF, zip imzası (`PK`) EPUB'dur.
  /// Uzantı yalnızca hata mesajını seçmek için kullanılır.
  static DigitalFormat detectFormat(String fileName, Uint8List bytes) {
    final isPdf =
        bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
    final isZip = bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;
    if (isPdf) return DigitalFormat.pdf;
    if (isZip) return DigitalFormat.text;
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf') || name.endsWith('.epub')) {
      throw const DigitalBookException(DigitalBookFailure.invalidFile);
    }
    throw const DigitalBookException(DigitalBookFailure.unsupportedFile);
  }

  /// Cihazdaki PDF'in baytları; kayıt var ama dosya kaybolmuşsa kaydı temizleyip `null` döner.
  Future<Uint8List?> readPdf(String bookId) async {
    final copy = await copyOf(bookId);
    if (copy == null || copy.format != DigitalFormat.pdf) return null;
    final bytes = await _files.readBytes(copy.fileName);
    if (bytes == null) await _removeCopy(bookId);
    return bytes;
  }

  /// PDF'in sayfa sayısı ilk açılışta öğrenilip kaydedilir.
  Future<void> updateLength(String bookId, int length) async {
    final copy = await copyOf(bookId);
    if (copy == null || copy.charCount == length) return;
    await _saveCopy(copy.copyWith(charCount: length));
  }

  /// Gutenberg metni çevrimiçiyse yeniden indirilir (ham metinden temizlik en
  /// doğru sonucu verir); çevrimdışıyken kayıtlı metin yeniden temizlenir.
  Future<String> _recleanedText(String text, BookModel book) async {
    final edition = book.digitalEdition;
    if (edition?.source == DigitalSource.gutenberg) {
      try {
        return _prepare(
          await _gutenberg.fetchText(edition!.sourceId),
          book.genre,
        );
      } on DigitalBookException {
        return _prepare(
          ReadingTextCleaner.cleanGutenbergMarkup(text),
          book.genre,
        );
      }
    }
    return _prepare(text, book.genre);
  }

  /// İndirilmiş metni okur; kayıt var ama dosya kaybolmuşsa kaydı temizleyip `null` döner.
  /// [book] verilirse eski kurallarla temizlenmiş kopya güncel kurallarla
  /// yeniden temizlenip kaydedilir (yeniden indirme gerekmez).
  Future<String?> readText(String bookId, {BookModel? book}) async {
    final copy = await copyOf(bookId);
    if (copy == null || copy.format != DigitalFormat.text) return null;
    final text = await _files.read(copy.fileName);
    if (text == null) {
      await _removeCopy(bookId);
      return null;
    }
    if (book == null || copy.textVersion >= ReadingTextCleaner.version) {
      return text;
    }
    return _reclean(copy, text, book);
  }

  Future<String> _reclean(
    DigitalCopyModel copy,
    String text,
    BookModel book,
  ) async {
    final cleaned = await _recleanedText(text, book);
    try {
      if (cleaned != text) await _files.write(copy.fileName, cleaned);
    } on Exception {
      return text;
    }
    // Kalınan yer, okuma oranı korunarak yeni metne taşınır.
    await _saveCopy(
      copy.copyWith(
        charCount: cleaned.length,
        lastOffset: (copy.progress * cleaned.length).round(),
        byteSize: utf8.encode(cleaned).length,
        textVersion: ReadingTextCleaner.version,
      ),
    );
    return cleaned;
  }

  Future<void> savePosition(String bookId, int offset) async {
    final copy = await copyOf(bookId);
    if (copy == null) return;
    final max = copy.charCount > 0 ? copy.charCount : offset;
    await _saveCopy(
      copy.copyWith(lastOffset: offset.clamp(0, max < 0 ? 0 : max)),
    );
  }

  Future<void> delete(String bookId) async {
    final copy = await copyOf(bookId);
    if (copy == null) return;
    await _files.delete(copy.fileName);
    await _removeCopy(bookId);
  }

  Future<void> _saveCopy(DigitalCopyModel copy) async {
    final copies = [
      for (final c in await getCopies())
        if (c.bookId != copy.bookId) c,
      copy,
    ];
    await _storage.writeJsonList(
      StorageKeys.digital,
      copies.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> _removeCopy(String bookId) async {
    final copies = (await getCopies()).where((c) => c.bookId != bookId);
    await _storage.writeJsonList(
      StorageKeys.digital,
      copies.map((c) => c.toJson()).toList(),
    );
  }
}
