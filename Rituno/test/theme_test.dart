import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutino/core/theme/app_theme.dart';
import 'package:rutino/core/constants/app_colors.dart';
import 'package:rutino/core/services/storage_service.dart';
import 'package:rutino/core/services/ai_service.dart';
import 'package:rutino/main.dart';
import 'package:rutino/features/habits/models/habit_model.dart';
import 'package:rutino/features/habits/widgets/habit_card_widget.dart';
import 'package:rutino/features/habits/widgets/habit_stats_banner_widget.dart';
import 'package:rutino/features/profile/widgets/profile_setting_tile_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rutino Tema & Okunabilirlik Testleri', () {
    test('Açık ve koyu tema brightness ve renk tanımları doğru olmalı', () {
      final lightTheme = AppTheme.light;
      final darkTheme = AppTheme.dark;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      expect(lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);

      expect(lightTheme.colorScheme.onSurface, AppColors.lightTextPrimary);
      expect(darkTheme.colorScheme.onSurface, AppColors.darkTextPrimary);
    });

    testWidgets('HabitCardWidget açık temada doğru arka plan ve yüksek kontrastla çizilmeli',
        (WidgetTester tester) async {
      const habit = HabitModel(
        id: '1',
        title: 'Kitap Oku',
        streakCount: 5,
        isCompletedToday: false,
        category: 'Zihin & Odak',
        reminderTime: '21:00',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: HabitCardWidget(
              habit: habit,
              onToggle: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kitap Oku'), findsOneWidget);
      expect(find.text('Zihin & Odak'), findsOneWidget);
      expect(find.text('21:00'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      final titleText = tester.widget<Text>(find.text('Kitap Oku'));
      expect(titleText.style?.color, AppColors.lightTextPrimary);
    });

    testWidgets('ProfileSettingTileWidget açık temada doğru renk ve metinlerle çizilmeli',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfileSettingTileWidget(
              icon: Icons.dark_mode_outlined,
              title: 'Koyu Tema',
              subtitle: 'Aydınlık Mod',
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
          ),
        ),
      );

      expect(find.text('Koyu Tema'), findsOneWidget);
      expect(find.text('Aydınlık Mod'), findsOneWidget);

      final titleText = tester.widget<Text>(find.text('Koyu Tema'));
      expect(titleText.style?.color, AppColors.lightTextPrimary);

      final subtitleText = tester.widget<Text>(find.text('Aydınlık Mod'));
      expect(subtitleText.style?.color, AppColors.lightTextSecondary);
    });

    testWidgets('RutinoApp tema anahtarı tıklandığında temayı sorunsuz değiştirmeli',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'rutino_dark_mode_v1': true});
      final storage = await StorageService.getInstance();
      final ai = AIService();

      await tester.pumpWidget(RutinoApp(
        storageService: storage,
        aiService: ai,
      ));
      await tester.pumpAndSettle();

      // Profil sekmesine geç
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      // Switch bileşenini bul ve tıkla
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Aydınlık moda geçmiş olmalı
      final appWidget = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(appWidget.themeMode, ThemeMode.light);
    });

    testWidgets('HabitStatsBannerWidget açık temada doğru metin renkleri ile çizilmeli',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: HabitStatsBannerWidget(
              total: 5,
              completed: 3,
              points: 450,
            ),
          ),
        ),
      );

      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('%60'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);

      final labelText = tester.widget<Text>(find.text('Hedef'));
      expect(labelText.style?.color, AppColors.lightTextSecondary);
    });
  });
}
