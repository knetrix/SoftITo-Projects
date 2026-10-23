import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/core/services/mock_data_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MockDataLoader boş depolamaya örnek harcamalar, bütçe, hedef ve challenge yükler', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();

    expect(storage.readJsonList(StorageKeys.expenses), isEmpty);
    expect(storage.readJsonList(StorageKeys.budgets), isEmpty);
    expect(storage.readJsonList(StorageKeys.goals), isEmpty);
    expect(storage.readJson(StorageKeys.activeChallenge), isNull);

    await MockDataLoader.loadMockDataIfEmpty(storage);

    expect(storage.readJsonList(StorageKeys.expenses), isNotEmpty);
    expect(storage.readJsonList(StorageKeys.budgets), hasLength(1));
    expect(storage.readJsonList(StorageKeys.goals), hasLength(2));
    expect(storage.readJson(StorageKeys.activeChallenge), isNotNull);
  });
}
