import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/app_dependencies.dart';
import 'core/services/settings_controller.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/register_view.dart';
import 'features/rental_map/views/rental_map_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  runApp(TiknowApp(deps: AppDependencies.create(storage)));
}

/// Kök widget. Tema + dil + oturum controller'ları `AppDependencies` içinde
/// tek örnek olarak yaşar ve constructor ile aşağı verilir.
class TiknowApp extends StatelessWidget {
  const TiknowApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: deps.settings.themeMode,
      builder: (context, mode, _) => ValueListenableBuilder<Locale>(
        valueListenable: deps.settings.locale,
        builder: (context, locale, _) => MaterialApp(
          title: 'Tiknow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          locale: locale,
          supportedLocales: SettingsController.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: RootRouter(deps: deps),
        ),
      ),
    );
  }
}

/// Oturum varsa harita, yoksa kayıt ekranı.
class RootRouter extends StatelessWidget {
  const RootRouter({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: deps.auth.state,
      builder: (context, state, _) {
        if (state == AuthState.authenticated) {
          return RentalMapView(deps: deps);
        }
        return RegisterView(auth: deps.auth);
      },
    );
  }
}
