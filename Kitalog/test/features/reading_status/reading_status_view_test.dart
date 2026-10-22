import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/reading_status/views/reading_status_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('sekmeler sayılarla görünür; okunuyor kartında yüzde ve sayaç vardır', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingStatusView()),
      size: const Size(800, 1600),
    );
    expect(find.text('Okunuyor (7)'), findsOneWidget);
    expect(find.text('Okunacak (12)'), findsOneWidget);
    expect(find.text('Bitti (12)'), findsOneWidget);
    expect(find.text('%70'), findsOneWidget);

    // Sekme sırası soldan sağa: Okunacak, Okunuyor, Bitti; açılışta Okunuyor seçili.
    final toReadX = tester.getCenter(find.text('Okunacak (12)')).dx;
    final readingX = tester.getCenter(find.text('Okunuyor (7)')).dx;
    final finishedX = tester.getCenter(find.text('Bitti (12)')).dx;
    expect(toReadX < readingX && readingX < finishedX, isTrue);
    expect(DefaultTabController.of(tester.element(find.byType(TabBar))).index, 1);

    // Okunuyor kartında hızlı sayaç yok; sayfa Kitap Detay'dan değiştirilir.
    expect(find.byTooltip('1 sayfa ileri'), findsNothing);
    expect(find.byTooltip('1 sayfa geri'), findsNothing);
    expect(find.text('%70'), findsOneWidget);
  });

  testWidgets('okunacak sekmesinde "Okumaya Başla" kitabı okunuyora taşır', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingStatusView()),
      size: const Size(800, 1600),
    );
    await tester.tap(find.text('Okunacak (12)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Okumaya Başla').first);
    await tester.pumpAndSettle();
    expect(find.text('Okunuyor (8)'), findsOneWidget);
    expect(find.text('Okunacak (11)'), findsOneWidget);
  });

  testWidgets('bitti sekmesi puan ve bitiş tarihini gösterir, boş durum mesajı çıkar', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingStatusView()),
      size: const Size(800, 1600),
    );
    await tester.tap(find.text('Bitti (12)'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_rounded), findsWidgets);
    expect(find.textContaining('Bitiş:'), findsWidgets);

    for (final book in deps.libraryController.books.value.toList()) {
      await deps.libraryController.deleteBook(book.id);
    }
    await tester.pumpAndSettle();
    expect(find.text('Henüz bitirdiğin kitap yok'), findsOneWidget);
  });
}
