import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/app_colors.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/utils/cover_image_data.dart';
import 'package:kitalog/core/widgets/book_cover_image.dart';

import '../helpers/fake_cover_picker.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

void main() {
  testWidgets('kapak adresi yoksa tür renginde başlıklı yer tutucu gösterilir', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(
        body: SizedBox(
          width: 100,
          height: 150,
          child: BookCoverImage(title: 'Dune', genre: BookGenre.sciFiFantasy),
        ),
      ),
    );
    expect(find.text('Dune'), findsOneWidget);
    final box = tester.widget<ColoredBox>(find.byType(ColoredBox).last);
    expect(box.color, AppColors.genreSciFiFantasy);
  });

  testWidgets('kapak yüklenemezse (internet yok / 404) yer tutucuya düşer', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(
        body: SizedBox(
          width: 100,
          height: 150,
          child: BookCoverImage(
            title: 'Cosmos',
            genre: BookGenre.science,
            coverUrl: 'https://covers.openlibrary.org/b/isbn/0000000000-L.jpg',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cosmos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cihazdan seçilen kapak (data URI) ağ isteği olmadan gösterilir', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      Scaffold(
        body: SizedBox(
          width: 100,
          height: 150,
          child: BookCoverImage(title: 'Defter', genre: BookGenre.other, coverUrl: CoverImageData.encode(tinyPng)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
    expect(find.text('Defter'), findsNothing);
  });

  testWidgets('bozuk cihaz kapağı yer tutucuya düşer', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(
        body: SizedBox(
          width: 100,
          height: 150,
          child: BookCoverImage(title: 'Defter', genre: BookGenre.other, coverUrl: 'data:image/png;base64,AAAA'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Defter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
