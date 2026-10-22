import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutino/core/services/storage_service.dart';
import 'package:rutino/core/services/ai_service.dart';
import 'package:rutino/main.dart';
import 'package:rutino/core/constants/app_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RutinoApp açılış ve arayüz duman testi', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.getInstance();
    final aiService = AIService();

    await tester.pumpWidget(RutinoApp(
      storageService: storageService,
      aiService: aiService,
    ));
    await tester.pumpAndSettle();

    // Giriş yapılmış varsayılan kullanıcı ile ana ekran veya başlık görülmeli
    expect(find.text(AppStrings.habitsTitle), findsOneWidget);
    expect(find.text(AppStrings.tabHabits), findsOneWidget);
    expect(find.text(AppStrings.tabStats), findsOneWidget);
  });
}
