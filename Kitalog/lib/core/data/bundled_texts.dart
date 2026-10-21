import '../models/digital_edition_model.dart';
import '../models/digital_source.dart';

/// Uygulamayla birlikte paketlenen dijital metinler.
///
/// Çok parçalı olduğu için kaynağından indirilmesi uzun süren eserler
/// (Nutuk: ~109 istek, ~40 sn) asset olarak gelir; "İndir" anında tamamlanır
/// ve ilk açılışta bile internet gerekmez. Dosyalar, uygulamanın kendi indirme
/// hattının (`WikisourceSource.fetchText`) çıktısıdır.
abstract final class BundledTexts {
  static const Map<String, String> _wikisource = {
    'Nutuk': 'assets/books/nutuk.txt',
  };

  /// Sürüm paketlenmişse asset yolunu, değilse `null` döner.
  static String? assetFor(DigitalEditionModel edition) {
    return switch (edition.source) {
      DigitalSource.wikisource => _wikisource[edition.sourceId],
      DigitalSource.gutenberg || DigitalSource.localFile => null,
    };
  }
}
