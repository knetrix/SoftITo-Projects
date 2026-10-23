import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/l10n/app_localizations.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/core/services/mock_data_loader.dart';
import 'package:money_habit_tracker/core/theme/app_theme.dart';
import 'package:money_habit_tracker/features/home/views/home_shell_view.dart';
import 'package:money_habit_tracker/features/settings/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeShellView 5 sekmeyi gösterir ve sekme geçişi yapar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();
    await MockDataLoader.loadMockDataIfEmpty(storage);
    final settingsController = SettingsController(storage);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('tr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeShellView(
          storage: storage,
          settingsController: settingsController,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // NavigationBar hedefleri doğrula
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));

    // İlk olarak Panel sekmesindeyiz (TR locale)
    expect(find.text('Panel'), findsWidgets);

    // Challenge sekmesine dokun
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();

    // Challenge sekmesi görünür olmalı
    expect(find.text('10 Günlük Challenge'), findsOneWidget);

    settingsController.dispose();
  });
}
