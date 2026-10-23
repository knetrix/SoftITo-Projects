import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/models/app_settings_model.dart';

class MoneyHabitApp extends StatefulWidget {
  final LocalStorageService storage;

  const MoneyHabitApp({super.key, required this.storage});

  @override
  State<MoneyHabitApp> createState() => _MoneyHabitAppState();
}

class _MoneyHabitAppState extends State<MoneyHabitApp> {
  late final SettingsController _settingsController;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController(widget.storage);
    _router = AppRouter(
      storage: widget.storage,
      settingsController: _settingsController,
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettingsModel>(
      valueListenable: _settingsController.state,
      builder: (context, settings, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: Locale(settings.localeCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: widget.storage.isLoggedIn
              ? AppRoutes.home
              : AppRoutes.register,
          onGenerateRoute: _router.onGenerateRoute,
        );
      },
    );
  }
}
