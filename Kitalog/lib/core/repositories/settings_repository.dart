import '../constants/storage_keys.dart';
import '../models/app_settings_model.dart';
import '../storage/local_storage_service.dart';

class SettingsRepository {
  const SettingsRepository(this._storage);

  final LocalStorageService _storage;

  Future<AppSettingsModel> get() async {
    final json = _storage.readJsonMap(StorageKeys.settings);
    return json == null
        ? const AppSettingsModel()
        : AppSettingsModel.fromJson(json);
  }

  Future<void> save(AppSettingsModel settings) {
    return _storage.writeJsonMap(StorageKeys.settings, settings.toJson());
  }
}
