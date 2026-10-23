import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/expense_model.dart';

class ExpensesController {
  final LocalStorageService _storage;
  final ValueNotifier<List<ExpenseModel>> expenses;
  final ValueNotifier<DateTime> selectedMonth;

  ExpensesController(this._storage)
      : expenses = ValueNotifier<List<ExpenseModel>>(
          _loadExpenses(_storage),
        ),
        selectedMonth = ValueNotifier<DateTime>(
          DateTime(DateTime.now().year, DateTime.now().month),
        );

  static List<ExpenseModel> _loadExpenses(LocalStorageService storage) {
    final list = storage.readJsonList(StorageKeys.expenses);
    final items = list.map(ExpenseModel.fromJson).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
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

  List<ExpenseModel> filteredExpenses(DateTime month) {
    return expenses.value
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
  }

  Map<DateTime, List<ExpenseModel>> groupedByDate(DateTime month) {
    final list = filteredExpenses(month);
    final grouped = <DateTime, List<ExpenseModel>>{};
    for (final item in list) {
      final day = item.date.dateOnly;
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  int totalForMonth(DateTime month) {
    return expenses.value
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, int> totalsByCategory(DateTime month) {
    final result = <ExpenseCategory, int>{};
    for (final e in expenses.value) {
      if (e.date.year != month.year || e.date.month != month.month) continue;
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Map<DateTime, int> expensesForLast7Days(DateTime now) {
    final today = now.dateOnly;
    final map = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      map[day] = 0;
    }
    for (final e in expenses.value) {
      final eDay = e.date.dateOnly;
      if (map.containsKey(eDay)) {
        map[eDay] = (map[eDay] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final updated = [expense, ...expenses.value];
    updated.sort((a, b) => b.date.compareTo(a.date));
    expenses.value = updated;
    await _persist();
  }

  Future<void> removeExpense(String id) async {
    expenses.value = expenses.value.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> restoreExpense(ExpenseModel expense, int originalIndex) async {
    final updated = List<ExpenseModel>.from(expenses.value);
    if (originalIndex >= 0 && originalIndex <= updated.length) {
      updated.insert(originalIndex, expense);
    } else {
      updated.add(expense);
    }
    updated.sort((a, b) => b.date.compareTo(a.date));
    expenses.value = updated;
    await _persist();
  }

  Future<void> _persist() => _storage.writeJsonList(
        StorageKeys.expenses,
        expenses.value.map((e) => e.toJson()).toList(),
      );

  void dispose() {
    expenses.dispose();
    selectedMonth.dispose();
  }
}
