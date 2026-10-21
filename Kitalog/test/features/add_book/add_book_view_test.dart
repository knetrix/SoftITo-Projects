import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/add_book/views/add_book_view.dart';

import '../../helpers/fake_open_library.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('arama sonucu seçilince form ön doldurulur ve kitap eklenir', (tester) async {
    final deps = await createTestDependencies(
      const {},
      fakeOpenLibrary(searchBody: cosmosSearchBody),
    );
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const AddBookView(), size: const Size(800, 1800));

    await tester.enterText(find.byType(TextField), 'cosmos');
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('Carl Sagan'), findsWidgets);

    await tester.tap(find.text('Cosmos').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Cosmos'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '365'), findsOneWidget);

    final before = deps.libraryController.books.value.length;
    await tester.tap(find.widgetWithText(FilledButton, 'Kitaplığa Ekle'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.books.value.length, before + 1);
    expect(deps.libraryController.books.value.first.isbn, '9780345539434');
  });

  testWidgets('sonuç yoksa "Manuel Ekle" yönlendirmesi çıkar ve form doğrulanır', (tester) async {
    final deps = await createTestDependencies(const {}, fakeOpenLibrary());
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const AddBookView(), size: const Size(800, 1800));

    await tester.enterText(find.byType(TextField), 'olmayan kitap');
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('Sonuç bulunamadı. Kitabı manuel ekleyebilirsin.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Manuel Ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Kitaplığa Ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Bu alan boş bırakılamaz.'), findsWidgets);
    expect(find.text('Sayfa sayısı 1 veya daha büyük bir sayı olmalı.'), findsNothing);
  });

  testWidgets('internet yokken hata mesajı ve tekrar dene seçeneği görünür', (tester) async {
    final deps = await createTestDependencies(const {}, fakeOpenLibrary(offline: true));
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const AddBookView(), size: const Size(800, 1800));
    await tester.enterText(find.byType(TextField), 'cosmos');
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('İnternet bağlantısı kurulamadı.'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.text('Manuel Ekle'), findsOneWidget);
  });

  testWidgets('geçersiz ISBN aramaya gitmeden uyarı verir', (tester) async {
    final deps = await createTestDependencies(const {}, fakeOpenLibrary());
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const AddBookView(), size: const Size(800, 1800));
    await tester.enterText(find.byType(TextField), '9780375508326');
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('Bu ISBN geçerli değil. Rakamları kontrol et.'), findsOneWidget);
  });

  testWidgets('manuel formda telefon dışı doğrulamalar: sayfa 0 ve hatalı URL reddedilir', (tester) async {
    final deps = await createTestDependencies(const {}, fakeOpenLibrary());
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const AddBookView(), size: const Size(800, 1800));
    await tester.tap(find.text('Manuel'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Kitap');
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.enterText(find.byType(TextFormField).at(3), 'abc');
    await tester.enterText(find.byType(TextFormField).at(4), 'ftp://x');
    await tester.pump();
    expect(find.text('Sayfa sayısı 1 veya daha büyük bir sayı olmalı.'), findsOneWidget);
    expect(find.text('Geçerli bir ISBN girin (10 veya 13 hane).'), findsOneWidget);
    expect(find.text('Geçerli bir http/https adresi girin.'), findsOneWidget);
  });
}
