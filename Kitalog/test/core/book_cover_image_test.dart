import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/app_colors.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/widgets/book_cover_image.dart';

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
}
