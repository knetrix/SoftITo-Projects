import '../constants/storage_keys.dart';
import '../models/quote_model.dart';
import '../storage/local_storage_service.dart';

class QuoteRepository {
  const QuoteRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<QuoteModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.quotes)
        .map(QuoteModel.fromJson)
        .toList();
  }

  Future<void> saveAll(List<QuoteModel> quotes) {
    return _storage.writeJsonList(
      StorageKeys.quotes,
      quotes.map((e) => e.toJson()).toList(),
    );
  }
}
