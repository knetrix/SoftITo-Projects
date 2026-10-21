import 'package:http/http.dart' as http;
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testlerde gerçek repository'ler sahte (mock) SharedPreferences ile çalışır.
Future<AppDependencies> createTestDependencies([
  Map<String, Object> initialValues = const {},
  http.Client? httpClient,
  DigitalFileStorage? digitalFiles,
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final storage = await LocalStorageService.create();
  // Dosya depolaması bellek içidir; testlerde path_provider eklentisi çalışmaz.
  return AppDependencies(
    storage,
    httpClient: httpClient,
    digitalFiles: digitalFiles ?? MemoryDigitalFileStorage(),
    sourceMinInterval: Duration.zero,
    // Sonsuz arka plan animasyonu `pumpAndSettle`ı bitirmez.
    animateDecorations: false,
  );
}

/// Doğrudan repository kurmak isteyen testler için mock SharedPreferences depolaması.
Future<LocalStorageService> testStorage([Map<String, Object> initialValues = const {}]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return LocalStorageService.create();
}
