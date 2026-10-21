import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/reader/views/reader_view.dart';
import 'package:kitalog/features/reader/widgets/reader_page_widget.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _frankId = 'seed-9781435136168';
final _text = List.generate(30, (i) => 'Bölüm $i ${'metin ' * 60}'.trim()).join('\n\n');

Future<AppDependencies> _open(WidgetTester tester, {bool offline = false}) async {
  final deps = await createTestDependencies(
    const {},
    FakeDigitalSources(gutenbergTexts: {'84': _text}, offline: offline).client,
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
    expect(find.text('Son sayfaya ulaştın. Kitabı bitirdin mi?'), findsOneWidget);
    await tester.tap(find.text('Bitti olarak işaretle'));
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
}
