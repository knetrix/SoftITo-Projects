/// Dijital metnin biçimi: düz metin okuyucuda (Gutenberg, Vikikaynak, EPUB)
/// sayfalanır; PDF orijinal sayfa düzeniyle gösterilir.
enum DigitalFormat {
  text,
  pdf;

  static DigitalFormat fromName(String? name) {
    return DigitalFormat.values.firstWhere(
      (e) => e.name == name,
      orElse: () => DigitalFormat.text,
    );
  }
}
