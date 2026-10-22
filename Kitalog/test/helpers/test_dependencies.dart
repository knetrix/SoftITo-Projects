import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/repositories/reminders/reminder_engine.dart';
import 'package:kitalog/core/repositories/translation/translation_engine.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testlerde gerçek repository'ler sahte (mock) SharedPreferences ile çalışır.
Future<AppDependencies> createTestDependencies([
  Map<String, Object> initialValues = const {},
  http.Client? httpClient,
  DigitalFileStorage? digitalFiles,
  // PDFium testlerde çalışmaz; PDF sayfa sayısı sahte sayaçtan gelir.
  Future<int> Function(Uint8List bytes)? countPdfPages,
  // Yerel çeviri motoru testlerde çalışmaz; çeviri testleri sahte motor verir, diğerlerinde çeviri kapalıdır.
  TranslationEngine? translationEngine,
  Future<String> Function(Uint8List bytes)? samplePdfText,
  // Yerel bildirim eklentisi testlerde çalışmaz; hatırlatma testleri sahte motor verir.
  ReminderEngine? reminderEngine,
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
    countPdfPages: countPdfPages ?? (_) async => 0,
    samplePdfText: samplePdfText ?? (_) async => '',
    translationEngine: translationEngine ?? const UnsupportedTranslationEngine(),
    reminderEngine: reminderEngine ?? const UnsupportedReminderEngine(),
  );
}

/// Doğrudan repository kurmak isteyen testler için mock SharedPreferences depolaması.
Future<LocalStorageService> testStorage([Map<String, Object> initialValues = const {}]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return LocalStorageService.create();
}
