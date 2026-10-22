/// Çevirinin ve dil tanımanın yapıldığı motor. Uygulama cihaz üstü yerel motoru
/// (Android'de Google ML Kit, iOS'ta Apple Translation) kullanır; testler sahte
/// motor verir. Motor değişirse (ör. bir çeviri API'si) yalnızca bu arayüzün
/// yeni bir uygulaması yazılır.
abstract class TranslationEngine {
  /// `false` ise (web, masaüstü, iOS simülatörü) okuyucuda çeviri gösterilmez.
  bool get isSupported;

  /// `true` ise dil paketini indirmeden önce sistem kendi onay penceresini
  /// gösterir (iOS); uygulama ayrıca onay sormaz.
  bool get systemConfirmsDownload;

  /// Metnin dil kodu (`en`, `tr`, ...); belirlenemezse boş metin.
  Future<String> identifyLanguage(String text);

  /// [from] → [to] çevirisi için gereken dil paketleri cihazda mı.
  Future<bool> areModelsDownloaded({required String from, required String to});

  /// Eksik dil paketlerini indirir; başarısızsa [TranslationException]
  /// (kullanıcı sistem penceresinde vazgeçerse [TranslationFailure.downloadDeclined]) fırlatır.
  Future<void> downloadModels({required String from, required String to});

  /// [text]'i [from] dilinden [to] diline çevirir; başarısızsa [TranslationException] fırlatır.
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  });

  Future<void> close();
}

enum TranslationFailure { modelDownload, downloadDeclined, translate }

class TranslationException implements Exception {
  const TranslationException(this.failure);

  final TranslationFailure failure;

  @override
  String toString() => 'TranslationException($failure)';
}

/// Çevirinin desteklenmediği platformlar (web, masaüstü, iOS simülatörü) için motor.
class UnsupportedTranslationEngine implements TranslationEngine {
  const UnsupportedTranslationEngine();

  @override
  bool get isSupported => false;

  @override
  bool get systemConfirmsDownload => false;

  @override
  Future<String> identifyLanguage(String text) async => '';

  @override
  Future<bool> areModelsDownloaded({
    required String from,
    required String to,
  }) async => false;

  @override
  Future<void> downloadModels({required String from, required String to}) async {
    throw const TranslationException(TranslationFailure.modelDownload);
  }

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    throw const TranslationException(TranslationFailure.translate);
  }

  @override
  Future<void> close() async {}
}
