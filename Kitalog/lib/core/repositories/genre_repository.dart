import '../constants/storage_keys.dart';
import '../models/custom_genre_model.dart';
import '../storage/local_storage_service.dart';

/// Kullanıcının eklediği kategorileri saklar ve okur.
class GenreRepository {
  const GenreRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<CustomGenreModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.genres)
        .map(CustomGenreModel.fromJson)
        .where((g) => g.id.isNotEmpty && g.name.isNotEmpty)
        .toList();
  }

  Future<void> saveAll(List<CustomGenreModel> genres) {
    return _storage.writeJsonList(
      StorageKeys.genres,
      genres.map((e) => e.toJson()).toList(),
    );
  }
}
