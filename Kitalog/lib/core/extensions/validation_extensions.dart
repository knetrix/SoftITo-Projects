import '../../l10n/generated/app_localizations.dart';
import '../utils/validators.dart';

extension ValidationErrorX on ValidationError {
  String message(AppLocalizations l10n) => switch (this) {
    ValidationError.required => l10n.errorRequired,
    ValidationError.emailInvalid => l10n.errorEmailInvalid,
    ValidationError.phoneInvalid => l10n.errorPhoneInvalid,
    ValidationError.passwordTooShort => l10n.errorPasswordTooShort,
    ValidationError.passwordNoUppercase => l10n.errorPasswordUppercase,
    ValidationError.passwordNoLowercase => l10n.errorPasswordLowercase,
    ValidationError.passwordNoDigit => l10n.errorPasswordDigit,
    ValidationError.passwordMismatch => l10n.errorPasswordMismatch,
    ValidationError.pageCountInvalid => l10n.errorPageCountInvalid,
    ValidationError.urlInvalid => l10n.errorUrlInvalid,
    ValidationError.isbnInvalid => l10n.errorIsbnInvalid,
    ValidationError.genreNameTooLong => l10n.errorGenreNameTooLong,
    ValidationError.genreNameTaken => l10n.errorGenreNameTaken,
  };
}
