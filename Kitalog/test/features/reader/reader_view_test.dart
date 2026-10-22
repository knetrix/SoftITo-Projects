import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/reader/views/reader_view.dart';
import 'package:kitalog/features/reader/widgets/reader_page_widget.dart';
import 'package:kitalog/features/reader/widgets/reader_translation_sheet.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/fake_translation_engine.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _frankId = 'seed-9781435136168';
final _text = List.generate(30, (i) => 'Bölüm $i ${'metin ' * 60}'.trim()).join('\n\n');

Future<AppDependencies> _open(
  WidgetTester tester, {
  bool offline = false,
  FakeTranslationEngine? engine,
}) async {
  final deps = await createTestDependencies(
    const {},
    FakeDigitalSources(gutenbergTexts: {'84': _text}, offline: offline).client,
    null,
    null,
    engine,
  );
  await deps.libraryController.load();
  await deps.settingsController.load();
  await pumpScreen(tester, deps, const ReaderView(bookId: _frankId), size: const Size(420, 900));
  return deps;
}

void main() {
  testWidgets('indirme çağrısı görünür; indirince ilk sayfa ve sayfa göstergesi çıkar', (tester) async {
    final deps = await _open(tester);
    expect(find.text('Frankenstein'), findsOneWidget);
    expect(find.text('Bu kitap henüz cihazında değil'), findsOneWidget);

    await tester.tap(find.text('İndir ve Oku'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderPageWidget), findsOneWidget);
    expect(find.textContaining('Bölüm 0'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^1 / \d+$')), findsOneWidget);
    expect(await deps.digitalBookRepository.copyOf(_frankId), isNotNull);
  });

  testWidgets('sonraki sayfa düğmesi sayfayı ilerletir ve konumu kaydeder', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.text('İndir ve Oku'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^2 / \d+$')), findsOneWidget);
    expect((await deps.digitalBookRepository.copyOf(_frankId))!.lastOffset, greaterThan(0));
  });

  testWidgets('seçilen metin "Alıntı olarak kaydet" ile kitabın alıntılarına eklenir', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.text('İndir ve Oku'));
    await tester.pumpAndSettle();
    final before = deps.libraryController.quotesOf(_frankId).length;

    final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
    await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
    await tester.pumpAndSettle();
    expect(find.text('Alıntı olarak kaydet'), findsOneWidget);

    await tester.tap(find.text('Alıntı olarak kaydet'));
    await tester.pumpAndSettle();
    final quotes = deps.libraryController.quotesOf(_frankId);
    expect(quotes.length, before + 1);
    expect(quotes.first.text, 'Bölüm');
    expect(quotes.first.page, 1);
    expect(find.text('Alıntı kaydedildi; kitap ayrıntılarındaki Alıntılar bölümüne eklendi.'), findsOneWidget);
    expect(find.text('Alıntı olarak kaydet'), findsNothing, reason: 'menü kapanır');

    // Varsayılan düğmeler (Kopyala vb.) korunur; dar ekranda "Diğer" altındadır.
    await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Diğer'));
    await tester.pumpAndSettle();
    expect(find.text('Kopyala'), findsOneWidget);
  });

  testWidgets('yazı boyutu ayarı kalıcı kaydedilir', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Yazı boyutu'));
    await tester.pumpAndSettle();
    final slider = find.descendant(of: find.byType(BottomSheet), matching: find.byType(Slider));
    await tester.drag(slider, const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(deps.settingsController.state.value.readerTextScale, greaterThan(1.0));
    expect((await deps.settingsRepository.get()).readerTextScale, greaterThan(1.0));
  });

  testWidgets('ağ yokken hata mesajı ve tekrar dene görünür', (tester) async {
    await _open(tester, offline: true);
    await tester.tap(find.text('İndir ve Oku'));
    await tester.pumpAndSettle();
    expect(find.text('İnternet bağlantısı kurulamadı. İndirmek için bağlantı gerekiyor.'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('son sayfaya gelince bitirme önerisi çıkar ve kitap bitirilir', (tester) async {
    const cpId = 'seed-9781435131828';
    final deps = await createTestDependencies(
      const {},
      FakeDigitalSources(gutenbergTexts: {'2554': _text}).client,
    );
    await deps.libraryController.load();
    await deps.settingsController.load();
    await pumpScreen(tester, deps, const ReaderView(bookId: cpId), size: const Size(420, 900));
    await tester.tap(find.text('İndir ve Oku'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Slider), const Offset(1000, 0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget, reason: 'Kitap Detay ile aynı onay penceresi');
    expect(find.text('Kitabı bitirdin mi?'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(FilledButton, 'Bitti olarak işaretle')));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(cpId)!.status.name, 'finished');
  });

  testWidgets('Nutuk ağ yokken paketten anında açılır', (tester) async {
    const nutukId = 'seed-9786051211879';
    final fake = FakeDigitalSources(offline: true);
    final deps = await createTestDependencies(const {}, fake.client);
    await deps.libraryController.load();
    await deps.settingsController.load();
    await pumpScreen(tester, deps, const ReaderView(bookId: nutukId), size: const Size(420, 900));
    await tester.runAsync(() async {
      await tester.tap(find.text('İndir ve Oku'));
      // Asset okuma gerçek G/Ç olduğu için sahte saat dışında beklenir.
      for (var i = 0; i < 50 && find.byType(ReaderPageWidget).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(find.byType(ReaderPageWidget), findsOneWidget);
    expect(fake.requests, isEmpty);
    // Seed'deki %30 ilerlemeden açılır, ilk sayfadan değil.
    expect(find.textContaining(RegExp(r'^1 / \d+$')), findsNothing);
  });

  group('çeviri', () {
    Future<AppDependencies> openReady(WidgetTester tester, FakeTranslationEngine engine) async {
      final deps = await _open(tester, engine: engine);
      await tester.tap(find.text('İndir ve Oku'));
      await tester.pumpAndSettle();
      return deps;
    }

    Future<void> chooseView(WidgetTester tester, String label) async {
      await tester.tap(find.byTooltip('Çeviri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('çeviri desteklenmiyorsa üst çubukta çeviri düğmesi yoktur', (tester) async {
      await openReady(tester, FakeTranslationEngine(supported: false));
      expect(find.byTooltip('Çeviri'), findsNothing);
    });

    testWidgets('menüde üç görünüm; "Türkçe çeviri" sayfayı çevrilmiş gösterir', (tester) async {
      await openReady(tester, FakeTranslationEngine());
      await tester.tap(find.byTooltip('Çeviri'));
      await tester.pumpAndSettle();
      expect(find.text('Orijinal'), findsOneWidget);
      expect(find.text('Türkçe çeviri'), findsOneWidget);
      expect(find.text('Orijinal ve çeviri alt alta'), findsOneWidget);

      await tester.tap(find.text('Türkçe çeviri'));
      await tester.pumpAndSettle();
      expect(find.textContaining('[tr] Bölüm 0'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^Bölüm 0')), findsNothing);
      expect(find.textContaining(RegExp(r'^1 / \d+$')), findsOneWidget, reason: 'sayfa numarası değişmez');

      await chooseView(tester, 'Orijinal');
      expect(find.textContaining('[tr]'), findsNothing);
    });

    testWidgets('"alt alta" görünümünde her paragrafın altında çevirisi vardır', (tester) async {
      await openReady(tester, FakeTranslationEngine());
      await chooseView(tester, 'Orijinal ve çeviri alt alta');
      final text = tester.widget<Text>(
        find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text)),
      );
      final plain = text.textSpan!.toPlainText();
      expect(plain, startsWith('Bölüm 0'));
      expect(plain, contains('\n[tr] Bölüm 0'));
      expect(plain, contains('\n[tr] Bölüm 1'));
    });

    testWidgets('sonraki sayfaya geçince o sayfa da çevrilmiş görünür', (tester) async {
      await openReady(tester, FakeTranslationEngine());
      await chooseView(tester, 'Türkçe çeviri');
      await tester.tap(find.byTooltip('Sonraki sayfa'));
      await tester.pumpAndSettle();
      expect(find.textContaining(RegExp(r'^2 / \d+$')), findsOneWidget);
      final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
      expect(tester.widget<Text>(page.last).data, startsWith('[tr]'));
    });

    testWidgets('dil paketi yoksa onay sorulur; vazgeçilince orijinal kalır', (tester) async {
      final engine = FakeTranslationEngine(downloaded: {});
      await openReady(tester, engine);
      await chooseView(tester, 'Türkçe çeviri');
      expect(find.text('Çeviri dil paketi indirilsin mi?'), findsOneWidget);

      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(find.textContaining('[tr]'), findsNothing);
      expect(engine.downloads, isEmpty);

      await chooseView(tester, 'Türkçe çeviri');
      await tester.tap(find.widgetWithText(FilledButton, 'İndir'));
      await tester.pumpAndSettle();
      expect(engine.downloads, unorderedEquals(['en', 'tr']));
      expect(find.textContaining('[tr] Bölüm 0'), findsOneWidget);
    });

    testWidgets('çeviri hatasında üstte mesaj ve "Tekrar dene" görünür', (tester) async {
      final engine = FakeTranslationEngine()..failTranslate = true;
      await openReady(tester, engine);
      await chooseView(tester, 'Türkçe çeviri');
      expect(find.text('Metin çevrilemedi.'), findsOneWidget);

      engine.failTranslate = false;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.text('Metin çevrilemedi.'), findsNothing);
      expect(find.textContaining('[tr] Bölüm 0'), findsOneWidget);
    });

    testWidgets('seçilen metin "Çevir" ile alttan açılan pencerede çevrilir ve alıntı kaydedilebilir', (tester) async {
      final deps = await openReady(tester, FakeTranslationEngine());
      final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
      await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
      await tester.pumpAndSettle();
      // "Çevir" menünün başında; dar ekranda "Alıntı olarak kaydet" "Diğer" altındadır.
      await tester.tap(find.byTooltip('Diğer'));
      await tester.pumpAndSettle();
      expect(find.text('Alıntı olarak kaydet'), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Çevir'));
      await tester.pumpAndSettle();

      expect(find.byType(ReaderTranslationSheet), findsOneWidget);
      expect(find.text('[tr] Bölüm'), findsOneWidget);
      expect(find.text('Cihazda yapılan otomatik çeviridir; hatalar içerebilir.'), findsOneWidget);

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.tap(find.text('Kopyala'));
      await tester.pumpAndSettle();
      expect(copied, '[tr] Bölüm');
      expect(find.byType(ReaderTranslationSheet), findsNothing);
      expect(find.text('Çeviri kopyalandı.'), findsOneWidget);

      // Yeniden seçip çevirince pencere tekrar açılır.
      await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Çevir'));
      await tester.pumpAndSettle();
      expect(find.text('[tr] Bölüm'), findsOneWidget);

      final before = deps.libraryController.quotesOf(_frankId).length;
      await tester.tap(find.descendant(of: find.byType(ReaderTranslationSheet), matching: find.text('Alıntı olarak kaydet')));
      await tester.pumpAndSettle();
      expect(find.byType(ReaderTranslationSheet), findsNothing);
      final quotes = deps.libraryController.quotesOf(_frankId);
      expect(quotes.length, before + 1);
      expect(quotes.first.text, 'Bölüm', reason: 'orijinal metin kaydedilir');
      expect(quotes.first.page, 1);
    });

    testWidgets('seçim çevirisinde dil paketi reddedilirse pencere kapanır', (tester) async {
      await openReady(tester, FakeTranslationEngine(downloaded: {}));
      final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
      await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Çevir'));
      // Onay beklenirken pencerede ilerleme göstergesi döner; pumpAndSettle bitmez.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ReaderTranslationSheet), findsOneWidget);
      expect(find.text('Çeviri dil paketi indirilsin mi?'), findsOneWidget);

      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(find.byType(ReaderTranslationSheet), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
