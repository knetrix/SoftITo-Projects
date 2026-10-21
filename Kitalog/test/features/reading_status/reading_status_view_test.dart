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

    // En yüksek ilerlemeli kitap (Self-Help, %70) listenin başındadır.
    final before = deps.libraryController.bookById('seed-9780192801760')!.currentPage;
    await tester.tap(find.byTooltip('1 sayfa ileri').first);
    await tester.pumpAndSettle();
    expect(
      deps.libraryController.bookById('seed-9780192801760')!.currentPage,
      before + 1,
    );
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
