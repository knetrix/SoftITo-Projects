import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/features/book_detail/controllers/book_file_picker.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';
import 'package:kitalog/features/book_detail/widgets/quote_tile_widget.dart';
import 'package:kitalog/features/reader/widgets/reader_page_widget.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_books.dart';
import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';
const _userId = 'kullanici-1';
final _text = List.generate(20, (i) => 'Bölüm $i ${'metin ' * 50}'.trim()).join('\n\n');

Future<AppDependencies> _open(
  WidgetTester tester,
  String bookId, {
  FakeDigitalSources? fake,
  BookFilePicker? picker,
}) async {
  final deps = await createTestDependencies(const {}, (fake ?? FakeDigitalSources(gutenbergTexts: {'2554': _text})).client);
  await deps.libraryController.load();
  await deps.settingsController.load();
  await deps.libraryController.addBook(
    BookModel(id: _userId, title: 'Sula', pageCount: 174, addedAt: DateTime(2026)),
  );
  await pumpScreen(
    tester,
    deps,
    BookDetailView(bookId: bookId, filePicker: picker),
    size: const Size(800, 3200),
  );
  return deps;
}

void main() {
  testWidgets('telifi bitmiş kitap: İndir → Oku → okuyucu açılır → cihazdan silinir', (tester) async {
    final deps = await _open(tester, _cpId);
    expect(find.textContaining('Project Gutenberg'), findsNothing, reason: 'kaynak satırı gösterilmez');
    expect(find.text('Dosya yükle (PDF / EPUB)'), findsNothing);
    await tester.tap(find.text('İndir (çevrimdışı okuma)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cihazda ('), findsNothing, reason: 'cihaz durumu satırı gösterilmez');

    await tester.tap(find.widgetWithText(FilledButton, 'Oku'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderPageWidget), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cihazdan sil'));
    await tester.pumpAndSettle();
    expect(find.text('İndir (çevrimdışı okuma)'), findsOneWidget);
    expect(await deps.digitalBookRepository.copyOf(_cpId), isNull);
  });

  testWidgets('okuyucuda seçilen metin alıntı olarak kaydedilir ve Alıntılar bölümünde görünür', (tester) async {
    final deps = await _open(tester, _cpId);
    final before = deps.libraryController.quotesOf(_cpId).length;
    await tester.tap(find.text('İndir (çevrimdışı okuma)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Oku'));
    await tester.pumpAndSettle();

    final page = find.descendant(of: find.byType(ReaderPageWidget), matching: find.byType(Text));
    await tester.longPressAt(tester.getTopLeft(page) + const Offset(20, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alıntı olarak kaydet'));
    await tester.pumpAndSettle();
    final quotes = deps.libraryController.quotesOf(_cpId);
    expect(quotes.length, before + 1);
    final saved = quotes.first;
    expect(saved.page, deps.libraryController.bookById(_cpId)!.currentPage, reason: 'okuyucudaki sayfa numarasıyla');
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    final tile = find.ancestor(of: find.text('“${saved.text}”'), matching: find.byType(QuoteTileWidget));
    expect(tile, findsOneWidget, reason: 'Alıntılar bölümüne otomatik eklenir');
    expect(find.descendant(of: tile, matching: find.text('s. ${saved.page}')), findsOneWidget);
  });

  testWidgets('kullanıcının kitabında arama yok; EPUB yüklenip okunur', (tester) async {
    final picker = FakeBookFilePicker(PickedBookFile(name: 'sula.epub', bytes: buildEpub()));
    final deps = await _open(tester, _userId, picker: picker);
    expect(find.text('Dijital sürüm ara'), findsNothing);
    expect(find.text('Dosya yükle (PDF / EPUB)'), findsOneWidget);

    await tester.tap(find.text('Dosya yükle (PDF / EPUB)'));
    await tester.pumpAndSettle();
    expect(find.text('Başka dosya yükle'), findsOneWidget);
    expect(deps.libraryController.bookById(_userId)!.digitalEdition?.sourceId, 'sula.epub');

    await tester.tap(find.widgetWithText(FilledButton, 'Oku'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Birinci bölümün metni.'), findsOneWidget);
  });

  testWidgets('kullanıcı dosyası cihazdan silinince yeniden yükleme ekranına dönülür', (tester) async {
    final picker = FakeBookFilePicker(PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()));
    final deps = await _open(tester, _userId, picker: picker);
    await tester.tap(find.text('Dosya yükle (PDF / EPUB)'));
    await tester.pumpAndSettle();
    expect(find.text('Cihazdan sil'), findsOneWidget);

    await tester.tap(find.text('Cihazdan sil'));
    await tester.pumpAndSettle();
    expect(find.text('Dosya yükle (PDF / EPUB)'), findsOneWidget);
    expect(deps.libraryController.bookById(_userId)!.hasDigitalEdition, isFalse);
  });

  testWidgets('kopya korumalı EPUB anlaşılır hata mesajı verir', (tester) async {
    final picker = FakeBookFilePicker(PickedBookFile(name: 'drm.epub', bytes: buildEpub(encrypted: true)));
    await _open(tester, _userId, picker: picker);
    await tester.tap(find.text('Dosya yükle (PDF / EPUB)'));
    await tester.pumpAndSettle();
    expect(find.text('Bu dosya kopya korumalı (DRM); korumalı kitaplar açılamaz.'), findsOneWidget);
    expect(find.text('Dosya yükle (PDF / EPUB)'), findsOneWidget);
  });

  testWidgets('kitap silinince cihazdaki dijital kopya da silinir', (tester) async {
    final deps = await _open(tester, _cpId);
    await tester.tap(find.text('İndir (çevrimdışı okuma)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kitabı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sil'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_cpId), isNull);
    expect(await deps.digitalBookRepository.copyOf(_cpId), isNull);
  });
}
