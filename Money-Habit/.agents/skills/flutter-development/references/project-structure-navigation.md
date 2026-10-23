# Project Structure & Navigation

## Klasör Yapısı

Tam Yapı `PROJECT_NEW.md` Bölüm 7'dedir. Özet:

```text
lib/
    core/        constants, extensions, l10n, router, services, theme, utils, widgets
    features/    auth, home, dashboard, challenge, goals, expenses, budget, settings
                 (her biri: controllers/ models/ views/ widgets/)
    app.dart
    main.dart
```

## l10n Kurulumu

```yaml
# l10n.yaml (proje kök dizini)
arb-dir: lib/core/l10n
template-arb-file: app_tr.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

```json
// lib/core/l10n/app_tr.arb
{
  "@@locale": "tr",
  "appTitle": "Money Habit Tracker",
  "navDashboard": "Panel",
  "navChallenge": "Challenge",
  "navGoals": "Hedeflerim",
  "navExpenses": "Harcamalar",
  "navBudget": "Bütçe"
}
```

> `app_en.arb` Aynı Anahtarları İngilizce Değerlerle İçerir. Değişiklikten Sonra `flutter gen-l10n` Çalıştırılır.

```dart
// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
```

## app.dart: Tema, Dil ve Rota Bağlantısı

Tema ve Dil Değişince Tüm Uygulamanın Yeniden Çizilmesi Gerekir; Bu Yüzden `MaterialApp` Tek Bir `ValueListenableBuilder` ile `SettingsController.state`'i Dinler.

```dart
// lib/app.dart
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
```

## AppRouter: İsimli Rotalar (Çekirdek Navigator)

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';

import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/views/home_shell_view.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../features/settings/views/settings_view.dart';
import '../services/local_storage_service.dart';

abstract final class AppRoutes {
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = '/settings';
}

class AppRouter {
  final LocalStorageService storage;
  final SettingsController settingsController;

  const AppRouter({required this.storage, required this.settingsController});

  Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final Widget page = switch (routeSettings.name) {
      AppRoutes.register => RegisterView(storage: storage),
      AppRoutes.login => LoginView(storage: storage),
      AppRoutes.home => HomeShellView(storage: storage),
      AppRoutes.settings => SettingsView(
          storage: storage,
          settingsController: settingsController,
        ),
      _ => RegisterView(storage: storage),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: routeSettings);
  }
}
```

### Navigasyon Kuralları

```dart
// Kayıt / Giriş başarılı → geri tuşu ile auth ekranına dönülemez
Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);

// Ayarlar (her sekmenin AppBar sağ üstündeki ikon)
Navigator.of(context).pushNamed(AppRoutes.settings);

// Çıkış yap → giriş ekranı, yığın temizlenir
Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
```

- Ana Sekmeler (Panel, Challenge, Hedeflerim, Harcamalar, Bütçe) Ayrı Rota DEĞİLDİR; `HomeShellView` İçinde `NavigationBar` + `IndexedStack` ile Gösterilir. Seçili Sekme İndeksi Yerel UI Durumudur (`ValueNotifier<int>` veya Küçük `StatefulWidget`).
- Form Ekranları (Harcama Ekle, Hedef Ekle, Para Ekle) Tercihen `showModalBottomSheet` ile Açılır ve Sonucu `Navigator.pop(context, result)` ile Döner.
