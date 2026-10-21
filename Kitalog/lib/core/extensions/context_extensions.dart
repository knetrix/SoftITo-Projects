import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Tarihi uygulama diline göre biçimlendirir (örn. 21 Eki 2026 / Oct 21, 2026).
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(Localizations.localeOf(this).languageCode)
        .format(date);
  }
}
