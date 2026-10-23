import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../expenses/models/expense_model.dart';
import '../models/budget_model.dart';

class BudgetController {
  final LocalStorageService _storage;
  final ValueNotifier<List<BudgetModel>> budgets;
  final ValueNotifier<DateTime> selectedMonth;

  BudgetController(this._storage)
      : budgets = ValueNotifier<List<BudgetModel>>(_loadBudgets(_storage)),
        selectedMonth = ValueNotifier<DateTime>(
          DateTime(DateTime.now().year, DateTime.now().month),
        );

  static List<BudgetModel> _loadBudgets(LocalStorageService storage) {
    final list = storage.readJsonList(StorageKeys.budgets);
    return list.map(BudgetModel.fromJson).toList();
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth.value = DateTime(month.year, month.month);
  }

  void previousMonth() {
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month - 1);
  }

  void nextMonth() {
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month + 1);
  }

  BudgetModel? getBudgetForMonth(String monthKey) {
    try {
      return budgets.value.firstWhere((b) => b.monthKey == monthKey);
    } catch (_) {
      return null;
    }
  }

  int getLimitForMonth(String monthKey) {
    return getBudgetForMonth(monthKey)?.limitAmount ?? 0;
  }

  List<ExpenseModel> _loadAllExpenses() {
    final list = _storage.readJsonList(StorageKeys.expenses);
    return list.map(ExpenseModel.fromJson).toList();
  }

  int getSpentForMonth(String monthKey) {
    final expenses = _loadAllExpenses();
    return expenses
        .where((e) => e.date.monthKey == monthKey)
        .fold(0, (sum, e) => sum + e.amount);
  }

  int getRemainingForMonth(String monthKey) {
    final limit = getLimitForMonth(monthKey);
    final spent = getSpentForMonth(monthKey);
    return limit - spent;
  }

  bool isOverBudget(String monthKey) {
    final limit = getLimitForMonth(monthKey);
    if (limit <= 0) return false;
    return getSpentForMonth(monthKey) > limit;
  }

  double getUsageRatio(String monthKey) {
    final limit = getLimitForMonth(monthKey);
    if (limit <= 0) return 0.0;
    final spent = getSpentForMonth(monthKey);
    return (spent / limit).clamp(0.0, 1.0);
  }

  Map<ExpenseCategory, int> getCategoryDistribution(String monthKey) {
    final expenses = _loadAllExpenses();
    final result = <ExpenseCategory, int>{};
    for (final e in expenses) {
      if (e.date.monthKey != monthKey) continue;
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Map<DateTime, int> getLast7DaysExpenses(DateTime now) {
    final today = now.dateOnly;
    final map = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      map[day] = 0;
    }
    final expenses = _loadAllExpenses();
    for (final e in expenses) {
      final eDay = e.date.dateOnly;
      if (map.containsKey(eDay)) {
        map[eDay] = (map[eDay] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Future<void> setBudgetLimit(String monthKey, int limitAmount) async {
    final existingIndex = budgets.value.indexWhere((b) => b.monthKey == monthKey);
    final updatedList = List<BudgetModel>.from(budgets.value);

    if (existingIndex >= 0) {
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        limitAmount: limitAmount,
      );
    } else {
      updatedList.add(BudgetModel(monthKey: monthKey, limitAmount: limitAmount));
    }

    budgets.value = updatedList;
    await _storage.writeJsonList(
      StorageKeys.budgets,
      updatedList.map((e) => e.toJson()).toList(),
    );
  }

  void refresh() {
    budgets.value = _loadBudgets(_storage);
  }

  void dispose() {
    budgets.dispose();
    selectedMonth.dispose();
  }
}
