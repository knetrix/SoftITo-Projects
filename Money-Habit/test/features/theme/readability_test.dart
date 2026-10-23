import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/app_colors.dart';
import 'package:money_habit_tracker/core/l10n/app_localizations.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/core/services/mock_data_loader.dart';
import 'package:money_habit_tracker/core/theme/app_theme.dart';
import 'package:money_habit_tracker/features/auth/views/login_view.dart';
import 'package:money_habit_tracker/features/auth/views/register_view.dart';
import 'package:money_habit_tracker/features/home/views/home_shell_view.dart';
import 'package:money_habit_tracker/features/settings/controllers/settings_controller.dart';
import 'package:money_habit_tracker/features/settings/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({
    required Widget home,
    required ThemeData theme,
  }) {
    return MaterialApp(
      theme: theme,
      locale: const Locale('tr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  group('Karanlık ve Aydınlık Mod Okunabilirlik Doğrulaması', () {
    testWidgets('Karanlık mod tema paleti ve tipografi renkleri uyumludur', (tester) async {
      final theme = AppTheme.dark;
      expect(theme.colorScheme.onSurface, equals(AppColors.darkTextPrimary));
      expect(theme.colorScheme.onSurfaceVariant, equals(AppColors.darkTextSecondary));
      expect(theme.colorScheme.onPrimary, equals(Colors.white));
      expect(theme.textTheme.bodySmall?.color, equals(AppColors.darkTextSecondary));
      expect(theme.textTheme.bodyMedium?.color, equals(AppColors.darkTextPrimary));
    });

    testWidgets('Aydınlık mod tema paleti ve tipografi renkleri uyumludur', (tester) async {
      final theme = AppTheme.light;
      expect(theme.colorScheme.onSurface, equals(AppColors.lightTextPrimary));
      expect(theme.colorScheme.onSurfaceVariant, equals(AppColors.lightTextSecondary));
      expect(theme.colorScheme.onPrimary, equals(Colors.white));
      expect(theme.textTheme.bodySmall?.color, equals(AppColors.lightTextSecondary));
      expect(theme.textTheme.bodyMedium?.color, equals(AppColors.lightTextPrimary));
    });

    testWidgets('HomeShellView karanlık modda tüm 5 sekmeyi sorunsuz görüntüler', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      await MockDataLoader.loadMockDataIfEmpty(storage);
      final settingsController = SettingsController(storage);

      await tester.pumpWidget(
        buildTestApp(
          home: HomeShellView(
            storage: storage,
            settingsController: settingsController,
          ),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();

      // Sekme 1: Panel
      expect(find.text('Bu Ayki Kalan Bütçe'), findsOneWidget);
      expect(find.text('En Yakın Hedef'), findsOneWidget);

      // Sekme 2: Challenge
      await tester.tap(find.byIcon(Icons.emoji_events_outlined));
      await tester.pumpAndSettle();
      expect(find.text('10 Günlük Challenge'), findsOneWidget);

      // Sekme 3: Hedeflerim
      await tester.tap(find.byIcon(Icons.flag_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Hedeflerim'), findsWidgets);

      // Sekme 4: Harcamalar
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Harcamalar'), findsWidgets);

      // Sekme 5: Bütçe
      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pumpAndSettle();
      expect(find.text('Aylık Bütçe Limiti'), findsOneWidget);

      settingsController.dispose();
    });

    testWidgets('HomeShellView aydınlık modda tüm 5 sekmeyi sorunsuz görüntüler', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      await MockDataLoader.loadMockDataIfEmpty(storage);
      final settingsController = SettingsController(storage);

      await tester.pumpWidget(
        buildTestApp(
          home: HomeShellView(
            storage: storage,
            settingsController: settingsController,
          ),
          theme: AppTheme.light,
        ),
      );
      await tester.pumpAndSettle();

      // Sekme 1: Panel
      expect(find.text('Bu Ayki Kalan Bütçe'), findsOneWidget);
      expect(find.text('En Yakın Hedef'), findsOneWidget);

      // Sekme 2: Challenge
      await tester.tap(find.byIcon(Icons.emoji_events_outlined));
      await tester.pumpAndSettle();
      expect(find.text('10 Günlük Challenge'), findsOneWidget);

      // Sekme 3: Hedeflerim
      await tester.tap(find.byIcon(Icons.flag_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Hedeflerim'), findsWidgets);

      // Sekme 4: Harcamalar
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Harcamalar'), findsWidgets);

      // Sekme 5: Bütçe
      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pumpAndSettle();
      expect(find.text('Aylık Bütçe Limiti'), findsOneWidget);

      settingsController.dispose();
    });

    testWidgets('SettingsView karanlık ve aydınlık modda düzgün render edilir', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final settingsController = SettingsController(storage);

      await tester.pumpWidget(
        buildTestApp(
          home: SettingsView(
            settingsController: settingsController,
            storage: storage,
          ),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Görünüm & Tema'), findsOneWidget);
      expect(find.text('Uygulama Dili'), findsOneWidget);

      await tester.pumpWidget(
        buildTestApp(
          home: SettingsView(
            settingsController: settingsController,
            storage: storage,
          ),
          theme: AppTheme.light,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayarlar'), findsOneWidget);

      settingsController.dispose();
    });

    testWidgets('Auth ekranları karanlık ve aydınlık modda düzgün render edilir', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      // LoginView Dark & Light
      await tester.pumpWidget(
        buildTestApp(
          home: LoginView(storage: storage),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giriş Yap'), findsWidgets);

      await tester.pumpWidget(
        buildTestApp(
          home: LoginView(storage: storage),
          theme: AppTheme.light,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giriş Yap'), findsWidgets);

      // RegisterView Dark & Light
      await tester.pumpWidget(
        buildTestApp(
          home: RegisterView(storage: storage),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kayıt Ol'), findsWidgets);

      await tester.pumpWidget(
        buildTestApp(
          home: RegisterView(storage: storage),
          theme: AppTheme.light,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kayıt Ol'), findsWidgets);
    });
  });
}
