import '../constants/storage_keys.dart';
import '../models/loan_record_model.dart';
import '../storage/local_storage_service.dart';

/// İadesi alınmış ödünç kayıtlarını (ödünç geçmişi) saklar ve okur.
class LoanHistoryRepository {
  const LoanHistoryRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<LoanRecordModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.loanHistory)
        .map(LoanRecordModel.fromJson)
        .where((r) => r.id.isNotEmpty && r.bookId.isNotEmpty)
        .toList();
  }

  Future<void> saveAll(List<LoanRecordModel> records) {
    return _storage.writeJsonList(
      StorageKeys.loanHistory,
      records.map((e) => e.toJson()).toList(),
    );
  }
}
