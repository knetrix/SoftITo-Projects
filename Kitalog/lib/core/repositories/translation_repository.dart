import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../storage/digital_file_storage.dart';
import 'translation/translation_engine.dart';

/// Okuyucudaki İngilizce ↔ Türkçe çeviri. Metin satır satır (düzyazıda her satır
/// bir paragraftır, şiirde bir dize) çevrilir; böylece paragraf ve dize yapısı
/// korunur. Çevrilen her satır kitaba ait önbellek dosyasında, satırın özetiyle
/// saklanır: aynı satır ikinci kez çevrilmez ve çeviri internetsiz açılır.
/// Sayfa sınırları değişse (ör. dosya yenilense) bile özet aynı kaldığı için
/// önbellek geçerliliğini korur.
class TranslationRepository {
  TranslationRepository({required this._engine, required this._files});

  final TranslationEngine _engine;
  final DigitalFileStorage _files;

  /// Önbellek dosya adı → (satır özeti → çeviri).
  final Map<String, Map<String, String>> _caches = {};

  static const Map<String, String> _pairs = {'en': 'tr', 'tr': 'en'};

  bool get isSupported => _engine.isSupported;

  /// Kaynak dilin çevrileceği dil; çeviri yalnızca İngilizce ↔ Türkçe.
  static String? targetFor(String sourceLanguage) => _pairs[sourceLanguage];

  /// Metnin dil kodu; belirlenemezse (veya platform desteklemiyorsa) boş metin.
  Future<String> detectLanguage(String text) async {
    if (!isSupported) return '';
    return _engine.identifyLanguage(text);
  }

  /// `true` ise dil paketi onayını sistem sorar (iOS); uygulama ayrıca sormaz.
  bool get systemConfirmsDownload => _engine.systemConfirmsDownload;

  /// Çeviri için gereken dil paketlerinden biri eksikse `true` (ilk çeviriden önce indirilmeli).
  Future<bool> needsModelDownload(String from, String to) async =>
      !await _engine.areModelsDownloaded(from: from, to: to);

  /// Eksik dil paketlerini indirir.
  Future<void> downloadModels(String from, String to) =>
      _engine.downloadModels(from: from, to: to);

  /// Satırları çevirir; boş satırlar boş kalır. Sonuç [lines] ile aynı uzunluktadır.
  Future<List<String>> translateLines(
    String bookId,
    List<String> lines, {
    required String from,
    required String to,
  }) async {
    final cacheName = cacheFileName(bookId, from, to);
    final cache = await _cache(cacheName);
    final result = <String>[];
    var changed = false;
    try {
      for (final line in lines) {
        final source = line.trim();
        if (source.isEmpty) {
          result.add('');
          continue;
        }
        final key = _key(source);
        var translated = cache[key];
        if (translated == null) {
          translated = (await _engine.translate(
            source,
            from: from,
            to: to,
          )).trim();
          cache[key] = translated;
          changed = true;
        }
        result.add(translated);
      }
    } finally {
      // Yarıda kesilse bile o ana kadar çevrilen satırlar saklanır.
      if (changed) await _save(cacheName, cache);
    }
    return result;
  }

  /// Seçilen metni çevirir; satır yapısı korunur.
  Future<String> translateText(
    String bookId,
    String text, {
    required String from,
    required String to,
  }) async {
    final lines = await translateLines(
      bookId,
      text.split('\n'),
      from: from,
      to: to,
    );
    return lines.join('\n');
  }

  /// Kitabın çeviri önbelleğini siler (dijital kopya silinince / değişince).
  Future<void> clearCache(String bookId) async {
    for (final entry in _pairs.entries) {
      final name = cacheFileName(bookId, entry.key, entry.value);
      _caches.remove(name);
      await _files.delete(name);
    }
  }

  static String cacheFileName(String bookId, String from, String to) =>
      DigitalFileStorage.fileNameFor(bookId, extension: '$from-$to.json');

  static String _key(String line) => sha1.convert(utf8.encode(line)).toString();

  Future<Map<String, String>> _cache(String name) async {
    final cached = _caches[name];
    if (cached != null) return cached;
    final map = <String, String>{};
    final raw = await _files.read(name);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            if (entry.value is String) map[entry.key] = entry.value as String;
          }
        }
      } on FormatException {
        // Bozuk önbellek yok sayılır; çeviriler yeniden üretilir.
      }
    }
    return _caches[name] = map;
  }

  Future<void> _save(String name, Map<String, String> cache) async {
    try {
      await _files.write(name, jsonEncode(cache));
    } on Exception {
      // Önbellek yazılamazsa çeviri yine gösterilir; yalnızca bir dahaki sefere yeniden çevrilir.
    }
  }

  Future<void> close() => _engine.close();
}
