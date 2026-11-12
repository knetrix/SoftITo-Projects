import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../services/firebase_providers.dart';
import '../../services/user_service.dart';

/// main() içinde yüklenip override edilir.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider override edilmeli'),
);

class AppSettings {
  const AppSettings({required this.themeMode, required this.locale});
  final ThemeMode themeMode;
  final Locale locale;

  String get themeKey => themeMode == ThemeMode.dark ? 'dark' : 'light';

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

/// Tema ve dil: yerelde `shared_preferences`'a, oturum varsa
/// `users/{uid}.settings`'e yazılır. Girişte kullanıcı belgesindeki ayar uygulanır.
class SettingsController extends Notifier<AppSettings> {
  static const _kTheme = 'themeMode';
  static const _kLocale = 'locale';

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  AppSettings build() {
    final p = ref.read(sharedPrefsProvider);
    ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (prev, next) {
      final u = next.value;
      if (u == null || prev?.value?.uid == u.uid) return;
      _apply(u.themeMode, u.locale, persistRemote: false);
    });
    return AppSettings(
      themeMode: p.getString(_kTheme) == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(p.getString(_kLocale) == 'en' ? 'en' : 'tr'),
    );
  }

  void _apply(String theme, String locale, {required bool persistRemote}) {
    state = AppSettings(
      themeMode: theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(locale == 'en' ? 'en' : 'tr'),
    );
    _prefs.setString(_kTheme, state.themeKey);
    _prefs.setString(_kLocale, state.locale.languageCode);
    final uid = ref.read(uidProvider);
    if (persistRemote && uid != null) {
      ref.read(userServiceProvider).updateSettings(
            uid,
            themeMode: state.themeKey,
            locale: state.locale.languageCode,
          );
    }
  }

  void setTheme(ThemeMode m) => _apply(
      m == ThemeMode.dark ? 'dark' : 'light', state.locale.languageCode,
      persistRemote: true);

  void setLocale(String code) =>
      _apply(state.themeKey, code, persistRemote: true);
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Onboarding bir kez gösterilir (§4.1).
final onboardingSeenProvider = Provider<bool>(
  (ref) => ref.watch(sharedPrefsProvider).getBool('onboardingSeen') ?? false,
);
