import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/app_assets.dart';
import 'core/di/app_dependencies.dart';
import 'core/repositories/translation/native_translation_engine.dart';
import 'core/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // OFL lisansı yazı tipiyle birlikte dağıtılmalıdır.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(AppAssets.brandFontLicense);
    yield LicenseEntryWithLineBreaks(const ['DM Serif Display'], text);
  });
  final storage = await LocalStorageService.create();
  // Çeviri motoru yerel tarafa sorularak seçilir (iOS simülatöründe çeviri gizlenir).
  final dependencies = AppDependencies(
    storage,
    translationEngine: await NativeTranslationEngine.create(),
  );
  await dependencies.settingsController.load();
  // Kitaplar splash'te yüklenince iade ve okuma hatırlatmaları kurulur (izin açılışta istenmez).
  await dependencies.notificationController.start();
  runApp(dependencies.scope(child: const KitalogApp()));
}
