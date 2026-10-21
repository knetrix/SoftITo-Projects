/// `localFile`: kullanıcının cihazdan yüklediği kendi PDF / EPUB dosyası.
enum DigitalSource {
  gutenberg,
  wikisource,
  localFile;

  static DigitalSource? fromName(String? name) {
    for (final source in DigitalSource.values) {
      if (source.name == name) return source;
    }
    return null;
  }
}
