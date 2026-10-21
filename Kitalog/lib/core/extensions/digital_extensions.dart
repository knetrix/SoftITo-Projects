import '../../l10n/generated/app_localizations.dart';
import '../repositories/digital_sources/source_http.dart';

extension DigitalBookFailureX on DigitalBookFailure {
  String message(AppLocalizations l10n) => switch (this) {
    DigitalBookFailure.network => l10n.readerErrorNetwork,
    DigitalBookFailure.server => l10n.readerErrorServer,
    DigitalBookFailure.notFound => l10n.readerErrorNotFound,
    DigitalBookFailure.storage => l10n.readerErrorStorage,
    DigitalBookFailure.unavailable => l10n.readerErrorUnavailable,
    DigitalBookFailure.unsupportedFile => l10n.fileErrorUnsupported,
    DigitalBookFailure.invalidFile => l10n.fileErrorInvalid,
    DigitalBookFailure.protectedFile => l10n.fileErrorProtected,
    DigitalBookFailure.tooLarge => l10n.fileErrorTooLarge,
    DigitalBookFailure.fileMissing => l10n.fileErrorMissing,
  };

  /// Yalnızca geçici hatalarda (ağ, sunucu) "Tekrar dene" anlamlıdır.
  bool get isRetryable =>
      this == DigitalBookFailure.network || this == DigitalBookFailure.server;
}
