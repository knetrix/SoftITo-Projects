import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'digital_file_storage.dart';

/// Metinleri `<uygulama belgeleri>/books/` altına UTF-8 dosya olarak yazar;
/// böylece kitaplar internet olmadan da açılır.
class IoDigitalFileStorage implements DigitalFileStorage {
  IoDigitalFileStorage({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getApplicationDocumentsDirectory;

  static const String folderName = 'books';

  final Future<Directory> Function() _baseDirectory;
  Directory? _directory;

  @override
  bool get isPersistent => true;

  Future<Directory> _dir() async {
    final cached = _directory;
    if (cached != null) return cached;
    final base = await _baseDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$folderName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return _directory = dir;
  }

  Future<File> _file(String fileName) async {
    final dir = await _dir();
    return File('${dir.path}${Platform.pathSeparator}$fileName');
  }

  @override
  Future<void> write(String fileName, String text) async {
    final file = await _file(fileName);
    // Yarım kalan yazma bozuk dosya bırakmasın diye önce geçici dosyaya yazılır.
    final temp = File('${file.path}.part');
    await temp.writeAsString(text, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> writeBytes(String fileName, Uint8List bytes) async {
    final file = await _file(fileName);
    final temp = File('${file.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<Uint8List?> readBytes(String fileName) async {
    final file = await _file(fileName);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  @override
  Future<String?> read(String fileName) async {
    final file = await _file(fileName);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> delete(String fileName) async {
    final file = await _file(fileName);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<int> sizeOf(String fileName) async {
    final file = await _file(fileName);
    return await file.exists() ? file.length() : 0;
  }
}

DigitalFileStorage createPlatformDigitalFileStorage() => IoDigitalFileStorage();
