import '../l10n/app_localizations.dart';
import '../utils/validators.dart';

extension ValidationErrorText on ValidationError {
  String message(AppLocalizations l10n) => switch (this) {
        ValidationError.required => l10n.errorRequired,
        ValidationError.invalidEmail => l10n.errorInvalidEmail,
        ValidationError.invalidPhone => l10n.errorInvalidPhone,
        ValidationError.weakPassword => l10n.errorWeakPassword,
        ValidationError.passwordMismatch => l10n.errorPasswordMismatch,
      };
}
