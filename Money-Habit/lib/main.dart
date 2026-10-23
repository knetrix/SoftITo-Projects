import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/mock_data_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.init();
  await MockDataLoader.loadMockDataIfEmpty(storage);
  runApp(MoneyHabitApp(storage: storage));
}
