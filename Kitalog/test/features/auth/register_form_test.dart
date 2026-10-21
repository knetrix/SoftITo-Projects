import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/auth/views/login_view.dart';
import 'package:kitalog/features/auth/views/register_view.dart';
import 'package:kitalog/features/auth/widgets/auth_background_widget.dart';
import 'package:kitalog/features/auth/widgets/auth_fit_layout.dart';
import 'package:kitalog/features/splash/views/splash_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('geçersiz bilgilerde hata mesajları görünür, kayıt yapılmaz', (
    tester,
  ) async {
    final deps = await createTestDependencies();
    await pumpKitalog(tester, deps);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(RegisterView), findsOneWidget);

    // Form, alttaki kitaba ayrılan alanın üstünde kaydırılır; düğmeye önce kaydırılır.
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Kayıt Ol'));
    await tester.pumpAndSettle();
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

  testWidgets(
    'telefon maskeli girilir ve geçerli form kullanıcıyı ana sayfaya götürür',
    (tester) async {
      final deps = await createTestDependencies();
      await pumpKitalog(tester, deps);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byType(TextFormField).at(0), 'Ali@Ornek.com');
      await tester.enterText(find.byType(TextFormField).at(1), '05321234567');
      await tester.enterText(find.byType(TextFormField).at(2), 'Abcdefg1');
      await tester.enterText(find.byType(TextFormField).at(3), 'Abcdefg1');
      await tester.pump();
      expect(find.text('0 (532) 123 45 67'), findsOneWidget);

      // Form, alttaki kitaba ayrılan alanın üstünde kaydırılır; düğmeye önce kaydırılır.
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Kayıt Ol'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Kayıt Ol'));
      await tester.pumpAndSettle();

      expect(deps.authController.user?.email, 'ali@ornek.com');
      expect(deps.authController.user?.phone, '05321234567');
      expect(find.byType(RegisterView), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    },
  );

  testWidgets('kayıtlı oturum varsa splash doğrudan ana sayfaya yönlendirir', (
    tester,
  ) async {
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

  Future<void> showAllErrors(WidgetTester tester) async {
    final submit = find.widgetWithText(FilledButton, 'Kayıt Ol');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
  }

  /// Kitap ya hiç çizilmez ya da tamamı kartın altında ve ekranın içindedir.
  void expectNoOverlap(WidgetTester tester, Size size) {
    expect(tester.takeException(), isNull);
    final layout = tester.renderObject<RenderAuthFitLayout>(
      find.byType(AuthFitLayout),
    );
    if (!layout.showsBook) return;
    final card = tester.getRect(find.byType(Card));
    final book = tester.getRect(find.byType(AuthBookWidget));
    expect(card.bottom, lessThanOrEqualTo(book.top));
    expect(book.bottom, lessThanOrEqualTo(size.height + 0.01));
  }

  const sizes = [
    Size(390, 844),
    Size(402, 874),
    Size(430, 932),
    Size(320, 568),
    Size(844, 390),
    Size(1280, 800),
  ];
  for (final size in sizes) {
    testWidgets(
      'kitap yarım görünmez, kartın üstüne binmez; hata mesajlarıyla ve büyük yazıyla da (${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        final deps = await createTestDependencies();
        for (final view in const [RegisterView(), LoginView()]) {
          await pumpScreen(tester, deps, view, size: size);
          expectNoOverlap(tester, size);
          if (view is RegisterView) {
            await showAllErrors(tester);
            expect(find.text('Bu alan boş bırakılamaz.'), findsNWidgets(4));
            expectNoOverlap(tester, size);
            // Sayfa sonuna kaydırıldığında da çakışma yok.
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -2000),
            );
            await tester.pumpAndSettle();
            expectNoOverlap(tester, size);
          }
        }
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, const RegisterView(), size: size);
        expectNoOverlap(tester, size);
      },
    );
  }

  testWidgets('yerleşimin kuru ölçümü gerçek boyutla aynıdır', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const RegisterView(),
      size: const Size(402, 874),
    );
    final layout = tester.renderObject<RenderAuthFitLayout>(
      find.byType(AuthFitLayout),
    );
    expect(layout.getDryLayout(layout.constraints), layout.size);
  });

  testWidgets('yaygın telefonda kitap Giriş ve Kayıt ekranında görünür', (
    tester,
  ) async {
    const size = Size(430, 932);
    final deps = await createTestDependencies();
    for (final view in const [LoginView(), RegisterView()]) {
      await pumpScreen(tester, deps, view, size: size);
      final layout = tester.renderObject<RenderAuthFitLayout>(
        find.byType(AuthFitLayout),
      );
      expect(layout.showsBook, isTrue, reason: '${view.runtimeType}');
    }
  });

  testWidgets(
    'tüm doğrulama hataları açıkken "Giriş yap" bağlantısına kaydırılıp dokunulabilir',
    (tester) async {
      final deps = await createTestDependencies();
      await pumpScreen(
        tester,
        deps,
        const RegisterView(),
        size: const Size(390, 844),
      );
      await showAllErrors(tester);
      final link = find.textContaining('Giriş yap');
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
    },
  );

  testWidgets('form sığıyorsa sayfa kaymaz ve kitap ekranın altında görünür', (
    tester,
  ) async {
    const size = Size(390, 844);
    final deps = await createTestDependencies();
    await pumpScreen(tester, deps, const LoginView(), size: size);
    final book = tester.getRect(find.byType(AuthBookWidget));
    expect(book.bottom, moreOrLessEquals(size.height));
  });

  testWidgets(
    'klavye açıkken arka plan yerinde kalır, form klavyenin üstünde kaydırılabilir',
    (tester) async {
      const size = Size(390, 844);
      const keyboard = 336.0;
      final deps = await createTestDependencies();
      await pumpScreen(tester, deps, const RegisterView(), size: size);
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
      addTearDown(tester.view.resetViewInsets);
      await tester.tap(find.byType(TextFormField).at(1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final background = tester.getRect(find.byType(AuthBackgroundWidget));
      expect(
        background.height,
        size.height,
        reason: 'klavye arka planı küçültüp yukarı itmez',
      );
      final formArea = tester.getRect(find.byType(SingleChildScrollView));
      expect(formArea.bottom, lessThanOrEqualTo(size.height - keyboard));
      final layout = tester.renderObject<RenderAuthFitLayout>(
        find.byType(AuthFitLayout),
      );
      expect(
        layout.showsBook,
        isFalse,
        reason: 'klavye açıkken kitap forma yer bırakır',
      );
      // Odaklanılan alan klavyenin üstünde görünür.
      final field = tester.getRect(find.byType(TextFormField).at(1));
      expect(field.bottom, lessThanOrEqualTo(size.height - keyboard));
      expect(field.top, greaterThanOrEqualTo(formArea.top));
    },
  );
}
