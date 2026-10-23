import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
  });

  test('isLoggedIn okuma ve yazma çalışır', () async {
    expect(storage.isLoggedIn, isFalse);
    await storage.setLoggedIn(true);
    expect(storage.isLoggedIn, isTrue);
  });

  test('readJson ve writeJson çalışır', () async {
    expect(storage.readJson('test_key'), isNull);

    final data = {'name': 'Test', 'value': 42};
    await storage.writeJson('test_key', data);

    final read = storage.readJson('test_key');
    expect(read, equals(data));
  });

  test('readJsonList ve writeJsonList çalışır', () async {
    expect(storage.readJsonList('list_key'), isEmpty);

    final list = [
      {'id': '1', 'amount': 100},
      {'id': '2', 'amount': 200},
    ];
    await storage.writeJsonList('list_key', list);

    final read = storage.readJsonList('list_key');
    expect(read, hasLength(2));
    expect(read[0]['id'], '1');
    expect(read[1]['amount'], 200);
  });
}
