import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';
import 'core/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  final dependencies = AppDependencies(storage);
  await dependencies.settingsController.load();
  runApp(dependencies.scope(child: const KitalogApp()));
}
