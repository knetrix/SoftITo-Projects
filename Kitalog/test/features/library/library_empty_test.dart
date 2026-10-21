import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/storage_keys.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/features/library/views/library_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('kitaplık boşken boş durum mesajı ve ekleme butonu görünür', (tester) async {
    final deps = await createTestDependencies({
      StorageKeys.seeded: true,
      StorageKeys.seedVersion: SeedData.version,
    });
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const LibraryView());
    expect(find.text('Kitaplığın henüz boş'), findsOneWidget);
    expect(find.text('Kitap Ekle'), findsOneWidget);
  });
}
