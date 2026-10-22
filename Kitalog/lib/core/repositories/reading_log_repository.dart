import '../constants/storage_keys.dart';
import '../models/reading_log_entry_model.dart';
import '../storage/local_storage_service.dart';

/// Günlük okuma kaydını (kitap + gün + ilerlenen sayfa) saklar ve okur.
class ReadingLogRepository {
  const ReadingLogRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<ReadingLogEntryModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.readingLog)
        .map(ReadingLogEntryModel.fromJson)
        .where((e) => e.bookId.isNotEmpty && e.pages > 0)
        .toList();
  }

  Future<void> saveAll(List<ReadingLogEntryModel> entries) {
    return _storage.writeJsonList(
      StorageKeys.readingLog,
      entries.map((e) => e.toJson()).toList(),
    );
  }
}
