import 'package:kitalog/core/repositories/translation/translation_engine.dart';

/// Yerel motor yerine kullanılan sahte motor. Harflerinin %1'inden fazlası Türkçe
/// harf olan metni `tr`, diğerini `en` tanır; çeviriyi `[hedef] metin` biçiminde üretir ve çağrıları sayar.
class FakeTranslationEngine implements TranslationEngine {
  FakeTranslationEngine({
    this.supported = true,
    this.systemConfirmsDownload = false,
    Set<String>? downloaded,
    this.detected,
  }) : downloaded = downloaded ?? {'en', 'tr'};

  final bool supported;

  /// `true` ise iOS gibi onayı sistem sorar; [declineDownload] sistem penceresinde vazgeçmeyi taklit eder.
  @override
  final bool systemConfirmsDownload;

  /// Cihazda olan dil paketleri.
  final Set<String> downloaded;

  /// Verilirse tanıma her zaman bunu döner ('' = belirlenemedi).
  final String? detected;

  bool failDownload = false;
  bool declineDownload = false;
  bool failTranslate = false;
  final List<String> translated = [];
  final List<String> downloads = [];
  final List<String> identified = [];

  static final RegExp _turkish = RegExp('[çğışöüÇĞİŞÖÜ]');
  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);

  @override
  bool get isSupported => supported;

  @override
  Future<String> identifyLanguage(String text) async {
    identified.add(text);
    if (detected != null) return detected!;
    if (text.trim().isEmpty) return '';
    final letters = _letter.allMatches(text).length;
    return _turkish.allMatches(text).length > letters / 100 ? 'tr' : 'en';
  }

  @override
  Future<bool> areModelsDownloaded({
    required String from,
    required String to,
  }) async => downloaded.contains(from) && downloaded.contains(to);

  /// Yalnızca eksik paketler indirilir ve [downloads]'a yazılır.
  @override
  Future<void> downloadModels({required String from, required String to}) async {
    if (declineDownload) {
      throw const TranslationException(TranslationFailure.downloadDeclined);
    }
    if (failDownload) {
      throw const TranslationException(TranslationFailure.modelDownload);
    }
    for (final code in [from, to]) {
      if (downloaded.add(code)) downloads.add(code);
    }
  }

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (failTranslate) {
      throw const TranslationException(TranslationFailure.translate);
    }
    translated.add(text);
    return '[$to] $text';
  }

  @override
  Future<void> close() async {}
}
