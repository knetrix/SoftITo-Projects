import 'package:http/http.dart' as http;
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testlerde gerçek repository'ler sahte (mock) SharedPreferences ile çalışır.
Future<AppDependencies> createTestDependencies([
  Map<String, Object> initialValues = const {},
  http.Client? httpClient,
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final storage = await LocalStorageService.create();
  return AppDependencies(storage, httpClient: httpClient);
}
