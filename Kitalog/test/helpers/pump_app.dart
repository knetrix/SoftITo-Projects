import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/app.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/di/app_scope.dart';
import 'package:kitalog/core/models/app_settings_model.dart';
import 'package:kitalog/core/routing/app_routes.dart';
import 'package:kitalog/core/theme/app_theme.dart';
import 'package:kitalog/l10n/generated/app_localizations.dart';

/// Uygulamayı (AppScope + KitalogApp) verilen bağımlılıklarla başlatır.
Future<void> pumpKitalog(WidgetTester tester, AppDependencies deps) async {
  await tester.pumpWidget(deps.scope(child: const KitalogApp()));
}

/// Tek bir ekranı AppScope, tema ve dil desteğiyle açar.
Future<void> pumpScreen(
  WidgetTester tester,
  AppDependencies deps,
  Widget screen, {
  Locale locale = const Locale('tr'),
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    deps.scope(
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// `KitalogApp` ile aynı tema/dil bağlantısına sahip, ama başlangıç ekranı verilebilen
/// MaterialApp (ayar değişince anında güncellenir).
class KitalogAppWithHome extends StatelessWidget {
  const KitalogAppWithHome({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettingsModel>(
      valueListenable: AppScope.of(context).settingsController.state,
      builder: (context, settings, _) => MaterialApp(
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
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: home,
      ),
    );
  }
}
