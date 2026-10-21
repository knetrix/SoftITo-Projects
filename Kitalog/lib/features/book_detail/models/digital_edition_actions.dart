import 'package:flutter/foundation.dart';

/// Dijital sürüm bölümünün widget'larının controller'ı tanımadan çağırdığı eylemler.
class DigitalEditionActions {
  const DigitalEditionActions({
    required this.download,
    required this.deleteCopy,
    required this.importFile,
  });

  final VoidCallback download;
  final VoidCallback deleteCopy;

  /// Kullanıcının kendi PDF / EPUB dosyasını seçip yükler.
  final VoidCallback importFile;
}
