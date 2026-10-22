import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutino/core/constants/app_strings.dart';
import 'package:rutino/core/services/storage_service.dart';
import 'package:rutino/core/services/ai_service.dart';
import 'package:rutino/features/profile/controllers/profile_controller.dart';
import 'package:rutino/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rutino Dil Değiştirme ve Yerelleştirme Birim Testleri', () {
    setUp(() {
      AppStrings.setLanguage('tr');
    });

    test('AppStrings Türkçe ve İngilizce sözlük karşılıkları doğru dönmeli', () {
      AppStrings.setLanguage('tr');
      expect(AppStrings.isEnglish, false);
      expect(AppStrings.tabHabits, 'Alışkanlıklar');
      expect(AppStrings.tabStats, 'İstatistikler');
      expect(AppStrings.habitsTitle, 'Bugünün Rutinleri');
      expect(AppStrings.targetLabel, 'Hedef');
      expect(AppStrings.dayLabels.first, 'Pzt');

      AppStrings.setLanguage('en');
      expect(AppStrings.isEnglish, true);
      expect(AppStrings.tabHabits, 'Habits');
      expect(AppStrings.tabStats, 'Statistics');
      expect(AppStrings.habitsTitle, "Today's Routines");
      expect(AppStrings.targetLabel, 'Target');
      expect(AppStrings.dayLabels.first, 'Mon');
    });

    test('ProfileController dil tercihini güncellemeli ve kalıcı kaydetmeli', () async {
      SharedPreferences.setMockInitialValues({'rutino_language_v1': 'tr'});
      final storage = await StorageService.getInstance();
      final controller = ProfileController(storage);

      expect(controller.languageNotifier.value, 'tr');

      await controller.setLanguage('en');
      expect(controller.languageNotifier.value, 'en');
      expect(storage.loadLanguage(), 'en');

      await controller.setLanguage('tr');
      expect(controller.languageNotifier.value, 'tr');
      expect(storage.loadLanguage(), 'tr');

      controller.dispose();
    });

    test('AIService geçerli dile göre tavsiye ve özet üretmeli', () async {
      final ai = AIService();

      AppStrings.setLanguage('en');
      final insightEn = await ai.analyzeHabits(userId: 'test', habits: []);
      expect(insightEn.generatedSummary.contains('active habits'), true);
      expect(insightEn.suggestions.first.contains('water'), true);

      AppStrings.setLanguage('tr');
      final insightTr = await ai.analyzeHabits(userId: 'test', habits: []);
      expect(insightTr.generatedSummary.contains('aktif bir alışkanlığın'), true);
      expect(insightTr.suggestions.first.contains('su içme'), true);
    });
  });

  group('Rutino Dil Değişimi Widget Entegrasyon Testleri', () {
    testWidgets('Profil ekranından İngilizce seçildiğinde tüm arayüz anında İngilizceye dönmeli',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'rutino_language_v1': 'tr',
        'rutino_dark_mode_v1': true,
      });
      final storage = await StorageService.getInstance();
      final ai = AIService();

      await tester.pumpWidget(RutinoApp(
        storageService: storage,
        aiService: ai,
      ));
      await tester.pumpAndSettle();

      // Başlangıçta Türkçe olmalı
      expect(find.text('Bugünün Rutinleri'), findsOneWidget);
      expect(find.text('Alışkanlıklar'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Profil sekmesine geç
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Dil ayarı satırına tıkla
      await tester.tap(find.text('Uygulama Dili'));
      await tester.pumpAndSettle();

      // Açılan modal bottom sheet içerisinden 'English' seç
      expect(find.text('English'), findsOneWidget);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Artık arayüzün tüm metinleri İngilizce olmalı!
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Alışkanlıklar sekmesine geri dön ve başlığı kontrol et
      await tester.tap(find.text('Habits'));
      await tester.pumpAndSettle();

      expect(find.text("Today's Routines"), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });
  });
}
