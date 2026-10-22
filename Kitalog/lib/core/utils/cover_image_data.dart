import 'dart:convert';
import 'dart:typed_data';

/// Cihazdan seçilen kapak resmi `BookModel.coverUrl` içinde `data:` URI olarak
/// (base64) saklanır. Profil resmiyle aynı yöntemdir: web dahil her platformda
/// kalıcıdır ve kitap silinince resim de kendiliğinden silinir.
abstract final class CoverImageData {
  static const String _prefix = 'data:image/';

  /// Resim baytlarını `data:image/<tür>;base64,...` biçimine çevirir.
  static String encode(Uint8List bytes) => 'data:${_mimeOf(bytes)};base64,${base64Encode(bytes)}';

  /// Kapak cihazdan mı seçildi (ağ adresi değil)?
  static bool isLocal(String? coverUrl) => coverUrl != null && coverUrl.startsWith(_prefix);

  static final Map<String, Uint8List> _cache = {};
  static const int _cacheSize = 32;

  /// `data:` URI'sindeki resim baytları; çözülemezse `null`. Raf görünümü her
  /// çizimde yeniden çözmesin diye son kullanılan kapaklar bellekte tutulur.
  static Uint8List? bytesOf(String coverUrl) {
    final cached = _cache.remove(coverUrl);
    if (cached != null) return _cache[coverUrl] = cached;
    final Uint8List bytes;
    try {
      bytes = UriData.parse(coverUrl).contentAsBytes();
    } on FormatException {
      return null;
    }
    if (_cache.length >= _cacheSize) _cache.remove(_cache.keys.first);
    return _cache[coverUrl] = bytes;
  }

  static String _mimeOf(Uint8List bytes) {
    bool starts(List<int> sign) {
      if (bytes.length < sign.length) return false;
      for (var i = 0; i < sign.length; i++) {
        if (bytes[i] != sign[i]) return false;
      }
      return true;
    }

    if (starts(const [0x89, 0x50, 0x4E, 0x47])) return 'image/png';
    if (starts(const [0x47, 0x49, 0x46])) return 'image/gif';
    if (starts(const [0x52, 0x49, 0x46, 0x46])) return 'image/webp';
    return 'image/jpeg';
  }
}
