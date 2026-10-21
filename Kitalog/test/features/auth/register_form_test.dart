import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/auth/views/register_view.dart';
import 'package:kitalog/features/splash/views/splash_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('geçersiz bilgilerde hata mesajları görünür, kayıt yapılmaz', (tester) async {
    final deps = await createTestDependencies();
    await pumpKitalog(tester, deps);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(RegisterView), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Kayıt Ol'));
    await tester.pump();
    expect(find.text('Bu alan boş bırakılamaz.'), findsNWidgets(4));

    await tester.enterText(find.byType(TextFormField).at(0), 'gecersiz');
    await tester.enterText(find.byType(TextFormField).at(2), 'abc');
    await tester.pump();
    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
    expect(find.text('Şifre en az 8 karakter olmalı.'), findsOneWidget);
    expect(deps.authController.user, isNull);
  });

  testWidgets('telefon maskeli girilir ve geçerli form kullanıcıyı ana sayfaya götürür', (tester) async {
    final deps = await createTestDependencies();
    await pumpKitalog(tester, deps);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byType(TextFormField).at(0), 'Ali@Ornek.com');
    await tester.enterText(find.byType(TextFormField).at(1), '05321234567');
    await tester.enterText(find.byType(TextFormField).at(2), 'Abcdefg1');
    await tester.enterText(find.byType(TextFormField).at(3), 'Abcdefg1');
    await tester.pump();
    expect(find.text('0 (532) 123 45 67'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Kayıt Ol'));
    await tester.pumpAndSettle();

    expect(deps.authController.user?.email, 'ali@ornek.com');
    expect(deps.authController.user?.phone, '05321234567');
    expect(find.byType(RegisterView), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('kayıtlı oturum varsa splash doğrudan ana sayfaya yönlendirir', (tester) async {
    final deps = await createTestDependencies();
    await deps.authController.register(
      email: 'a@b.com',
      phone: '05321234567',
      password: 'Abcdefg1',
    );
    await pumpKitalog(tester, deps);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(RegisterView), findsNothing);
    expect(find.byType(SplashView), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
