import '../constants/storage_keys.dart';
import '../models/note_model.dart';
import '../storage/local_storage_service.dart';

class NoteRepository {
  const NoteRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<NoteModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.notes)
        .map(NoteModel.fromJson)
        .toList();
  }

  Future<void> saveAll(List<NoteModel> notes) {
    return _storage.writeJsonList(
      StorageKeys.notes,
      notes.map((e) => e.toJson()).toList(),
    );
  }
}
