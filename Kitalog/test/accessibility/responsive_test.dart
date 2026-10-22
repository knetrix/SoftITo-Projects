import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/add_book/views/add_book_view.dart';
import 'package:kitalog/features/add_book/widgets/manual_book_form_widget.dart';
import 'package:kitalog/features/auth/views/forgot_password_view.dart';
import 'package:kitalog/features/auth/views/login_view.dart';
import 'package:kitalog/features/auth/views/register_view.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';
import 'package:kitalog/features/home_shell/views/home_shell_view.dart';
import 'package:kitalog/features/library/views/library_view.dart';
import 'package:kitalog/features/loans/views/loans_view.dart';
import 'package:kitalog/features/reader/views/reader_view.dart';
import 'package:kitalog/features/reader/widgets/reader_page_widget.dart';
import 'package:kitalog/features/reader/widgets/reader_translation_sheet.dart';
import 'package:kitalog/features/reading_goal/views/reading_goal_view.dart';
import 'package:kitalog/features/reading_status/views/reading_status_view.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../helpers/fake_cover_picker.dart';
import '../helpers/fake_digital_sources.dart';
import '../helpers/fake_translation_engine.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

const _sizes = <String, Size>{
  'küçük telefon 320x568': Size(320, 568),
  'telefon 390x844': Size(390, 844),
  'tablet 820x1180': Size(820, 1180),
  'masaüstü 1280x800': Size(1280, 800),
};

const _textScales = [1.0, 1.6];

typedef _ScreenBuilder = Widget Function();

final _screens = <String, _ScreenBuilder>{
  'Kayıt': () => const RegisterView(),
  'Giriş': () => const LoginView(),
  'Şifremi unuttum': () => const ForgotPasswordView(),
  'Ana kabuk (Kitaplığım)': () => const HomeShellView(
    pages: [LibraryView(), ReadingStatusView(), LoansView(), ReadingGoalView()],
  ),
  'Okuma durumu': () => const Scaffold(body: ReadingStatusView()),
  'Ödünç takibi': () => const Scaffold(body: LoansView()),
  'Hedef paneli': () => const Scaffold(body: ReadingGoalView()),
  'Kitap detayı': () => const BookDetailView(bookId: 'seed-9781435131828'),
  'Kitap ekle': () => const AddBookView(),
  'Ayarlar': () => const SettingsView(),
  'Okuyucu (indirilmemiş)': () => const ReaderView(bookId: 'seed-9781435131828'),
};

Future<AppDependencies> _deps() async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  await deps.authController.register(
    email: 'a@b.com',
    phone: '05321234567',
    password: 'Abcdefg1',
  );
  return deps;
}

void main() {
  for (final screen in _screens.entries) {
    for (final size in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets(
          '${screen.key} – ${size.key}, yazı ölçeği $scale taşma/istisna üretmez',
          (tester) async {
            final deps = await _deps();
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            await pumpScreen(tester, deps, screen.value(), size: size.value);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Manuel form (tür / durum menüleri, kapak önizlemesi ve düğmeleri) hem URL
  // alanıyla hem cihazdan seçilen resimle her ekran ve yazı boyutunda sığmalı.
  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('Kitap ekle (manuel, cihaz kapağı) – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final deps = await _deps();
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, AddBookView(coverPicker: FakeCoverPicker(bytes: tinyPng)), size: size.value);
        await tester.tap(find.text('Manuel'));
        await tester.pumpAndSettle();
        // Formun dikey listesi (metin alanlarının yatay kaydırıcıları değil).
        final form = find.descendant(
          of: find.byType(ManualBookFormWidget),
          matching: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down),
        );
        await tester.scrollUntilVisible(find.text('Galeriden seç').hitTestable(), 100, scrollable: form.first);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Galeriden seç'));
        await tester.pumpAndSettle();
        expect(find.text('Resmi kaldır'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('Yeni kategori penceresi – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final deps = await _deps();
        await deps.libraryController.addCustomGenre('Uzun adlı bir kullanıcı kategorisi');
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, AddBookView(coverPicker: FakeCoverPicker()), size: size.value);
        await tester.tap(find.text('Manuel'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Yeni kategori ekle'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Filtre paneli (tüm bölümler, uzun adlı kategori) ve seçili filtre çipleri.
  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('Kitaplığım filtre paneli – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final deps = await _deps();
        await deps.libraryController.addCustomGenre('Uzun adlı bir kullanıcı kategorisi');
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, const LibraryView(), size: size.value);
        await tester.tap(find.byTooltip('Filtreler'));
        await tester.pumpAndSettle();
        for (final label in ['Dijital', 'Fiziksel', 'Uzun adlı bir kullanıcı kategorisi']) {
          final chip = find.descendant(of: find.byType(BottomSheet), matching: find.widgetWithText(FilterChip, label));
          await tester.ensureVisible(chip);
          await tester.pumpAndSettle();
          await tester.tap(chip);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        // Bu seçimle eşleşen kitap yok; düğme "Eşleşen kitap yok" der ama paneli yine kapatır.
        expect(find.text('Eşleşen kitap yok'), findsOneWidget);
        await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.byType(FilledButton)));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Filtreler (3 seçili)'), findsOneWidget);
        expect(find.byType(InputChip), findsWidgets);
        // Seçili filtre satırı yatay kayar; sonundaki "Temizle"ye kadar taşma olmamalı.
        await tester.scrollUntilVisible(
          find.widgetWithText(TextButton, 'Temizle'),
          200,
          scrollable: find.ancestor(of: find.byType(InputChip).first, matching: find.byType(Scrollable)).first,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('"Kitabı bitirdin mi?" penceresi – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final deps = await _deps();
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, const BookDetailView(bookId: 'seed-9781435131828'), size: size.value);
        await deps.libraryController.setCurrentPage('seed-9781435131828', 550);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('1 sayfa ileri'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('1 sayfa ileri'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Şifremi unuttum 2. adım: hata bandı + uzun e-postalı bilgi metni + iki şifre alanı.
  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('Şifremi unuttum (yeni şifre adımı) – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final deps = await _deps();
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, const ForgotPasswordView(), size: size.value);
        await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
        await tester.enterText(find.byType(TextFormField).at(1), '05321234567');
        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Devam'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Devam'));
        await tester.pumpAndSettle();
        expect(find.text('a@b.com hesabı doğrulandı. Yeni şifreni belirle.'), findsOneWidget);
        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Şifreyi Güncelle'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Şifreyi Güncelle'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('İngilizce dilde ana kabuk taşma üretmez (küçük ekran)', (tester) async {
    final deps = await _deps();
    await pumpScreen(
      tester,
      deps,
      const HomeShellView(pages: [LibraryView(), ReadingStatusView(), LoansView(), ReadingGoalView()]),
      locale: const Locale('en'),
      size: const Size(320, 568),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('My Library'), findsWidgets);
  });

  for (final size in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('Okuyucu (metin açık) – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
        final text = List.generate(20, (i) => 'Paragraf $i ${'uzunca kelime ' * 50}').join('\n\n');
        final deps = await createTestDependencies(
          const {},
          FakeDigitalSources(gutenbergTexts: {'2554': text}).client,
        );
        await deps.libraryController.load();
        await deps.settingsController.setReaderTextScale(1.8);
        final book = deps.libraryController.bookById('seed-9781435131828')!;
        await deps.digitalBookRepository.download(book);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, deps, const ReaderView(bookId: 'seed-9781435131828'), size: size.value);
        expect(find.byType(PageView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Çeviri: "alt alta" görünüm ve seçim çevirisi penceresi; hata durumunda üst bant
  // ve penceredeki hata satırı (simge + mesaj + "Tekrar dene").
  for (final failing in [false, true]) {
    for (final size in _sizes.entries) {
      for (final scale in _textScales) {
        final name = failing ? 'hata' : 'alt alta + pencere';
        testWidgets('Okuyucu çevirisi ($name) – ${size.key}, yazı ölçeği $scale taşma üretmez', (tester) async {
          final text = List.generate(20, (i) => 'Paragraf $i ${'uzunca kelime ' * 50}').join('\n\n');
          final engine = FakeTranslationEngine()..failTranslate = failing;
          final deps = await createTestDependencies(
            const {},
            FakeDigitalSources(gutenbergTexts: {'2554': text}).client,
            null,
            null,
            engine,
          );
          await deps.libraryController.load();
          await deps.settingsController.setReaderTextScale(1.8);
          await deps.digitalBookRepository.download(deps.libraryController.bookById('seed-9781435131828')!);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpScreen(tester, deps, const ReaderView(bookId: 'seed-9781435131828'), size: size.value);
          await tester.tap(find.byTooltip('Çeviri'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Orijinal ve çeviri alt alta'));
          await tester.pumpAndSettle();
          expect(find.text('Metin çevrilemedi.'), failing ? findsOneWidget : findsNothing);
          expect(tester.takeException(), isNull);

          final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
          await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Çevir'));
          await tester.pumpAndSettle();
          expect(find.byType(ReaderTranslationSheet), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
