import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/utils/cover_image_data.dart';
import 'package:kitalog/features/add_book/controllers/cover_picker.dart';
import 'package:kitalog/features/add_book/views/add_book_view.dart';

import '../../helpers/fake_cover_picker.dart';
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
    await tester.enterText(find.byType(TextFormField).at(3), 'ftp://x');
    await tester.enterText(find.byType(TextFormField).at(4), 'abc');
    await tester.pump();
    expect(find.text('Sayfa sayısı 1 veya daha büyük bir sayı olmalı.'), findsOneWidget);
    expect(find.text('Geçerli bir ISBN girin (10 veya 13 hane).'), findsOneWidget);
    expect(find.text('Geçerli bir http/https adresi girin.'), findsOneWidget);
  });

  group('manuel formda cihazdan kapak resmi', () {
    Future<dynamic> openManual(WidgetTester tester, FakeCoverPicker picker) async {
      final deps = await createTestDependencies(const {}, fakeOpenLibrary());
      await deps.libraryController.load();
      await pumpScreen(tester, deps, AddBookView(coverPicker: picker), size: const Size(800, 1800));
      await tester.tap(find.text('Manuel'));
      await tester.pumpAndSettle();
      return deps;
    }

    testWidgets('galeriden seçilen resim önizlenir, URL\'in yerine geçer ve kitapla kaydedilir', (tester) async {
      final picker = FakeCoverPicker(bytes: tinyPng);
      final deps = await openManual(tester, picker);
      expect(find.text('Kapak URL (isteğe bağlı)'), findsOneWidget);

      await tester.tap(find.text('Galeriden seç'));
      await tester.pumpAndSettle();
      expect(picker.lastSource, CoverSource.gallery);
      expect(find.byType(Image), findsOneWidget, reason: 'önizleme');
      expect(find.text('Kapak URL (isteğe bağlı)'), findsNothing);
      expect(find.text('Cihazdan seçilen resim kapak olarak kullanılacak.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Defterim');
      await tester.enterText(find.byType(TextFormField).at(2), '120');
      await tester.tap(find.widgetWithText(FilledButton, 'Kitaplığa Ekle'));
      await tester.pumpAndSettle();
      final book = deps.libraryController.books.value.first;
      expect(book.title, 'Defterim');
      expect(CoverImageData.isLocal(book.coverUrl), isTrue);
      expect(CoverImageData.bytesOf(book.coverUrl!), tinyPng);
    });

    testWidgets('resim kaldırılınca URL alanı geri gelir; kamera yalnızca destekleniyorsa görünür', (tester) async {
      final picker = FakeCoverPicker(bytes: tinyPng, camera: false);
      await openManual(tester, picker);
      expect(find.text('Fotoğraf çek'), findsNothing);
      await tester.tap(find.text('Galeriden seç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resmi kaldır'));
      await tester.pumpAndSettle();
      expect(find.text('Kapak URL (isteğe bağlı)'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('kamerayla çekilen resim kullanılır; seçici hata verirse mesaj gösterilir', (tester) async {
      final picker = FakeCoverPicker(bytes: tinyPng);
      await openManual(tester, picker);
      await tester.tap(find.text('Fotoğraf çek'));
      await tester.pumpAndSettle();
      expect(picker.lastSource, CoverSource.camera);
      expect(find.byType(Image), findsOneWidget);

      picker.shouldThrow = true;
      await tester.tap(find.text('Galeriden seç'));
      await tester.pumpAndSettle();
      expect(find.text('Resim seçilemedi. Lütfen tekrar dene.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget, reason: 'önceki resim korunur');
    });

    testWidgets('vazgeçilirse hiçbir şey değişmez', (tester) async {
      await openManual(tester, FakeCoverPicker());
      await tester.tap(find.text('Galeriden seç'));
      await tester.pumpAndSettle();
      expect(find.text('Kapak URL (isteğe bağlı)'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });

  group('manuel formda hızlı kategori ekleme', () {
    Future<dynamic> openManual(WidgetTester tester) async {
      final deps = await createTestDependencies(const {}, fakeOpenLibrary());
      await deps.libraryController.load();
      await pumpScreen(tester, deps, AddBookView(coverPicker: FakeCoverPicker()), size: const Size(800, 1800));
      await tester.tap(find.text('Manuel'));
      await tester.pumpAndSettle();
      return deps;
    }

    Finder dialogField() => find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextFormField));

    testWidgets('yeni kategori eklenir, formda seçili gelir ve kitapla kaydedilir', (tester) async {
      final deps = await openManual(tester);
      await tester.tap(find.byTooltip('Yeni kategori ekle'));
      await tester.pumpAndSettle();
      expect(find.text('Yeni kategori'), findsOneWidget);

      await tester.enterText(dialogField(), '  Mizah ');
      await tester.tap(find.byTooltip('Renk 4'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Ekle'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final created = deps.libraryController.customGenres.value.single;
      expect(created.name, 'Mizah');
      expect(created.colorIndex, 3);
      expect(find.text('Mizah'), findsWidgets, reason: 'Tür alanında seçili');

      await tester.enterText(find.byType(TextFormField).at(0), 'Gülmece');
      await tester.enterText(find.byType(TextFormField).at(2), '150');
      await tester.tap(find.widgetWithText(FilledButton, 'Kitaplığa Ekle'));
      await tester.pumpAndSettle();
      final book = deps.libraryController.books.value.first;
      expect(book.title, 'Gülmece');
      expect(book.customGenreId, created.id);
      expect(book.genre, BookGenre.other);
    });

    testWidgets('var olan tür veya kategori adı reddedilir; vazgeçilirse bir şey eklenmez', (tester) async {
      final deps = await openManual(tester);
      await deps.libraryController.addCustomGenre('Polisiye');
      await tester.tap(find.byTooltip('Yeni kategori ekle'));
      await tester.pumpAndSettle();

      for (final name in ['roman', 'POLİSİYE', '']) {
        await tester.enterText(dialogField(), name);
        await tester.tap(find.widgetWithText(FilledButton, 'Ekle'));
        await tester.pump();
        expect(find.byType(AlertDialog), findsOneWidget, reason: name);
      }
      await tester.enterText(dialogField(), 'roman');
      await tester.tap(find.widgetWithText(FilledButton, 'Ekle'));
      await tester.pump();
      expect(find.text('Bu kategori zaten var; listeden seçebilirsin.'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Vazgeç'));
      await tester.pumpAndSettle();
      expect(deps.libraryController.customGenres.value.length, 1);
    });

    testWidgets('eklenen kategoriler tür menüsünde listelenir', (tester) async {
      final deps = await openManual(tester);
      await deps.libraryController.addCustomGenre('Polisiye');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diğer'));
      await tester.pumpAndSettle();
      expect(find.text('Polisiye'), findsWidgets);
    });
  });

  testWidgets('"fiziksel olarak var" kapatılırsa kitap fiziksel kopyasız kaydedilir', (tester) async {
    final deps = await createTestDependencies(const {}, fakeOpenLibrary());
    await deps.libraryController.load();
    await pumpScreen(tester, deps, AddBookView(coverPicker: FakeCoverPicker()), size: const Size(800, 1800));
    await tester.tap(find.text('Manuel'));
    await tester.pumpAndSettle();
    final toggle = find.widgetWithText(SwitchListTile, 'Bu kitap bende fiziksel olarak var');
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue, reason: 'varsayılan açık');
    await tester.tap(toggle);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), 'İstek Listesi');
    await tester.enterText(find.byType(TextFormField).at(2), '90');
    await tester.tap(find.widgetWithText(FilledButton, 'Kitaplığa Ekle'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.books.value.first.isOwned, isFalse);
  });
}
