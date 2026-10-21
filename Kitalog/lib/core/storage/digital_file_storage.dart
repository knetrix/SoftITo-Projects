import 'dart:typed_data';

/// Dijital kitap metinlerinin saklandığı yer. Gerçek uygulama dosya sistemini
/// (`path_provider`) kullanır; web ve testler bellek içi sürümü kullanır.
abstract class DigitalFileStorage {
  /// `false` ise metin yalnızca oturum boyunca tutulur (çevrimdışı saklama yok).
  bool get isPersistent;

  Future<void> write(String fileName, String text);

  /// Dosya yoksa `null` döner.
  Future<String?> read(String fileName);

  Future<void> writeBytes(String fileName, Uint8List bytes);

  /// Dosya yoksa `null` döner.
  Future<Uint8List?> readBytes(String fileName);

  Future<void> delete(String fileName);

  /// Bayt cinsinden boyut; dosya yoksa 0.
  Future<int> sizeOf(String fileName);

  /// Kitap kimliğinden dosya sistemi için güvenli bir dosya adı üretir.
  static String fileNameFor(String bookId, {String extension = 'txt'}) {
    final safe = bookId.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return '$safe.$extension';
  }
}

/// Web ve testler için bellek içi depolama.
class MemoryDigitalFileStorage implements DigitalFileStorage {
  final Map<String, String> _files = {};
  final Map<String, Uint8List> _binaries = {};

  @override
  bool get isPersistent => false;

  @override
  Future<void> write(String fileName, String text) async {
    _files[fileName] = text;
  }

  @override
  Future<String?> read(String fileName) async => _files[fileName];

  @override
  Future<void> writeBytes(String fileName, Uint8List bytes) async {
    _binaries[fileName] = bytes;
  }

  @override
  Future<Uint8List?> readBytes(String fileName) async => _binaries[fileName];

  @override
  Future<void> delete(String fileName) async {
    _files.remove(fileName);
    _binaries.remove(fileName);
  }

  @override
  Future<int> sizeOf(String fileName) async =>
      _binaries[fileName]?.length ?? _files[fileName]?.length ?? 0;
}
