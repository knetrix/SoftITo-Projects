import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/app_scope.dart';
import 'core/models/app_settings_model.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

/// MaterialApp; tema ve dil `SettingsController` değiştikçe anında güncellenir.
class KitalogApp extends StatelessWidget {
  const KitalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettingsModel>(
      valueListenable: AppScope.of(context).settingsController.state,
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: Locale(settings.localeCode),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
