import '../constants/storage_keys.dart';
import '../models/reading_goal_model.dart';
import '../storage/local_storage_service.dart';

class GoalRepository {
  const GoalRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<ReadingGoalModel>> getAll() async {
    return _storage
        .readJsonList(StorageKeys.goals)
        .map(ReadingGoalModel.fromJson)
        .toList();
  }

  Future<void> saveAll(List<ReadingGoalModel> goals) {
    return _storage.writeJsonList(
      StorageKeys.goals,
      goals.map((e) => e.toJson()).toList(),
    );
  }
}
