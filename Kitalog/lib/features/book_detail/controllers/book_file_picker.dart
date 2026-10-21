import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Kullanıcının seçtiği kitap dosyası.
@immutable
class PickedBookFile {
  const PickedBookFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Cihazdan PDF / EPUB seçimi. Testte sahte bir uygulama verilebilir.
abstract class BookFilePicker {
  /// Vazgeçilirse `null` döner.
  Future<PickedBookFile?> pick();
}

class PlatformBookFilePicker implements BookFilePicker {
  const PlatformBookFilePicker();

  static const List<String> extensions = ['pdf', 'epub'];

  @override
  Future<PickedBookFile?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (file == null) return null;
    return PickedBookFile(name: file.name, bytes: await file.readAsBytes());
  }
}
