import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/goal_model.dart';

class GoalsController {
  final LocalStorageService _storage;
  final ValueNotifier<List<GoalModel>> goals;

  GoalsController(this._storage)
      : goals = ValueNotifier<List<GoalModel>>(_loadGoals(_storage));

  static List<GoalModel> _loadGoals(LocalStorageService storage) {
    final list = storage.readJsonList(StorageKeys.goals);
    return list.map(GoalModel.fromJson).toList();
  }

  Future<void> addGoal({
    required String title,
    required int targetAmount,
  }) async {
    final newGoal = GoalModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      targetAmount: targetAmount,
      steps: const [],
      createdAt: DateTime.now(),
    );

    goals.value = [newGoal, ...goals.value];
    await _persist();
  }

  Future<void> deleteGoal(String id) async {
    goals.value = goals.value.where((g) => g.id != id).toList();
    await _persist();
  }

  Future<void> addStep(
    String goalId, {
    required int amount,
    String? note,
  }) async {
    final step = GoalStepModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: DateTime.now(),
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );

    final updated = goals.value.map((g) {
      if (g.id == goalId) {
        return g.copyWith(steps: [step, ...g.steps]);
      }
      return g;
    }).toList();

    goals.value = updated;
    await _persist();
  }

  GoalModel? getNearestGoal() {
    final unreached = goals.value.where((g) => !g.isReached).toList();
    if (unreached.isEmpty) {
      return goals.value.isNotEmpty ? goals.value.first : null;
    }
    unreached.sort((a, b) => b.progress.compareTo(a.progress));
    return unreached.first;
  }

  Future<void> _persist() => _storage.writeJsonList(
        StorageKeys.goals,
        goals.value.map((g) => g.toJson()).toList(),
      );

  void refresh() {
    goals.value = _loadGoals(_storage);
  }

  void dispose() {
    goals.dispose();
  }
}
