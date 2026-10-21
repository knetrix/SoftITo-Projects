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
}
