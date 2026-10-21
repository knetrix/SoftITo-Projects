import '../constants/storage_keys.dart';
import '../models/book_model.dart';
import '../storage/local_storage_service.dart';

class BookRepository {
  const BookRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<BookModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.books)
        .map(BookModel.fromJson)
        .toList();
  }

  Future<void> saveAll(List<BookModel> books) {
    return _storage.writeJsonList(
      StorageKeys.books,
      books.map((e) => e.toJson()).toList(),
    );
  }

  Future<bool> isSeeded() async => _storage.readBool(StorageKeys.seeded);

  Future<void> markSeeded() => _storage.writeBool(StorageKeys.seeded, true);

  /// Yüklü örnek verinin sürümü; ilk sürümde anahtar yoktu (1 sayılır).
  Future<int> seedVersion() async => _storage.readInt(StorageKeys.seedVersion, defaultValue: 1);

  Future<void> saveSeedVersion(int version) => _storage.writeInt(StorageKeys.seedVersion, version);
}
