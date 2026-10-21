import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/storage_keys.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('JSON yazılır ve geri okunur; olmayan anahtar boş döner', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    expect(storage.readJsonMap('x'), isNull);
    expect(storage.readJsonList('x'), isEmpty);
    expect(storage.readBool('x'), isFalse);
    await storage.writeJsonMap('m', {'a': 1});
    await storage.writeJsonList('l', [
      {'b': 2},
    ]);
    await storage.writeBool('b', true);
    expect(storage.readJsonMap('m'), {'a': 1});
    expect(storage.readJsonList('l'), [
      {'b': 2},
    ]);
    expect(storage.readBool('b'), isTrue);
    await storage.remove('b');
    expect(storage.readBool('b'), isFalse);
  });

  test('bozuk JSON uygulamayı çökertmez, varsayılan döner', () async {
    SharedPreferences.setMockInitialValues({
      'bozuk-map': '{kırık',
      'bozuk-list': 'null',
      'liste-degil': '{"a":1}',
    });
    final storage = await LocalStorageService.create();
    expect(storage.readJsonMap('bozuk-map'), isNull);
    expect(storage.readJsonList('bozuk-list'), isEmpty);
    expect(storage.readJsonList('liste-degil'), isEmpty);
  });

  test('bozuk kitap verisi olsa bile kitaplık boş listeyle açılır', () async {
    final deps = await createTestDependencies({
      StorageKeys.books: '[[[bozuk',
      StorageKeys.seeded: true,
      StorageKeys.seedVersion: SeedData.version,
    });
    await deps.libraryController.load();
    expect(deps.libraryController.books.value, isEmpty);
    expect(deps.libraryController.goalTargetFor(2026), 12);
  });
}
