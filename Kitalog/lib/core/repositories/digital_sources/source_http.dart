import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum DigitalBookFailure {
  network,
  server,
  notFound,
  storage,
  unavailable,

  /// Kullanıcı dosyası: PDF/EPUB değil.
  unsupportedFile,

  /// Kullanıcı dosyası: bozuk veya okunamıyor.
  invalidFile,

  /// Kullanıcı dosyası: kopya korumalı (DRM) EPUB.
  protectedFile,

  /// Kullanıcı dosyası: boyut sınırını aşıyor.
  tooLarge,

  /// Kullanıcı dosyası cihazda bulunamadı (yeniden yüklenmeli).
  fileMissing,
}

class DigitalBookException implements Exception {
  const DigitalBookException(this.failure);

  final DigitalBookFailure failure;

  @override
  String toString() => 'DigitalBookException($failure)';
}

/// Dijital kaynaklar için ortak HTTP istemcisi: zaman aşımı, tanıtıcı başlık ve
/// hata eşlemesi (`BookSearchRepository` ile aynı desen).
class SourceHttp {
  SourceHttp({
    required this._client,
    this.timeout = const Duration(seconds: 30),
    this.maxAttempts = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.minInterval = const Duration(milliseconds: 350),
  });

  /// Wikimedia 2026 sınır politikası: iletişim bilgisi (URL veya e-posta) içeren
  /// User-Agent dakikada 200 istek alır, tanımlanamayan istemci yalnızca 10.
  static const String contactUrl = 'https://github.com/knetrix/SoftITo-Projects/tree/main/Kitalog';
  static const String _agent = 'Kitalog/1.0 ($contactUrl) dart-http';

  /// İstemci kendini tanıtır. HTTP başlıkları yalnızca ASCII olabilir;
  /// Türkçe karakter istek göndermeyi engeller.
  /// Tarayıcı `User-Agent`'ın değiştirilmesine izin vermediği için web'de
  /// yalnızca `Api-User-Agent` gönderilir.
  static Map<String, String> get headers => {
    'Api-User-Agent': _agent,
    if (!kIsWeb) 'User-Agent': _agent,
  };

  final http.Client _client;
  final Duration timeout;
  final int maxAttempts;
  final Duration retryDelay;

  /// İstekler arası en kısa süre: ~170 istek/dk, Wikimedia'nın 200/dk sınırının altında kalır.
  final Duration minInterval;
  DateTime? _lastRequest;

  Future<String> getText(Uri uri) => _send(() => _client.get(uri, headers: headers));

  /// Uzun parametreler (ör. 50 sayfa başlığı) URL sınırını aşmasın diye form gövdesiyle gönderilir.
  Future<Map<String, dynamic>> postJson(Uri uri, Map<String, String> fields) {
    return _decodeJson(_send(() => _client.post(uri, headers: headers, body: fields)));
  }

  Future<Map<String, dynamic>> getJson(Uri uri) => _decodeJson(getText(uri));

  /// 429 (çok fazla istek) ve 503 yanıtlarında `Retry-After` süresi kadar
  /// bekleyip yeniden dener.
  Future<String> _send(Future<http.Response> Function() request) async {
    for (var attempt = 1; ; attempt++) {
      await _pace();
      final http.Response response;
      try {
        response = await request().timeout(timeout);
      } on Exception {
        // TimeoutException, ClientException, soket hataları → ağ hatası.
        throw const DigitalBookException(DigitalBookFailure.network);
      }
      final code = response.statusCode;
      if ((code == 429 || code == 503) && attempt < maxAttempts) {
        final seconds = int.tryParse(response.headers['retry-after'] ?? '');
        await Future<void>.delayed(
          seconds != null ? Duration(seconds: seconds.clamp(1, 30)) : retryDelay * attempt,
        );
        continue;
      }
      if (code == 404) throw const DigitalBookException(DigitalBookFailure.notFound);
      if (code != 200) throw const DigitalBookException(DigitalBookFailure.server);
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    }
  }

  Future<void> _pace() async {
    final last = _lastRequest;
    if (last != null && minInterval > Duration.zero) {
      final wait = minInterval - DateTime.now().difference(last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    _lastRequest = DateTime.now();
  }

  Future<Map<String, dynamic>> _decodeJson(Future<String> text) async {
    final body = await text;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Aşağıda sunucu hatası olarak bildirilir.
    }
    throw const DigitalBookException(DigitalBookFailure.server);
  }
}
