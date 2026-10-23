import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/expenses/controllers/expenses_controller.dart';
import 'package:money_habit_tracker/features/expenses/models/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late ExpensesController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    controller = ExpensesController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('başlangıçta harcama listesi boştur', () {
    expect(controller.expenses.value, isEmpty);
    expect(controller.totalForMonth(DateTime.now()), 0);
  });

  test('addExpense harcama ekler ve depolamaya kaydeder', () async {
    final expense = ExpenseModel(
      id: 'e1',
      amount: 15000, // 150.00 TL
      category: ExpenseCategory.market,
      date: DateTime(2026, 10, 15),
      note: 'Market alışverişi',
    );

    await controller.addExpense(expense);
    expect(controller.expenses.value, hasLength(1));
    expect(controller.expenses.value.first.id, 'e1');
    expect(controller.totalForMonth(DateTime(2026, 10)), 15000);

    final stored = storage.readJsonList(StorageKeys.expenses);
    expect(stored, hasLength(1));
    expect(stored.first['amount'], 15000);
  });

  test('removeExpense ve restoreExpense doğru çalışır', () async {
    final e1 = ExpenseModel(
      id: 'e1',
      amount: 5000,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 10, 10),
    );
    final e2 = ExpenseModel(
      id: 'e2',
      amount: 12000,
      category: ExpenseCategory.bills,
      date: DateTime(2026, 10, 12),
    );

    await controller.addExpense(e1);
    await controller.addExpense(e2);
    expect(controller.expenses.value, hasLength(2));

    await controller.removeExpense('e1');
    expect(controller.expenses.value, hasLength(1));
    expect(controller.expenses.value.first.id, 'e2');

    await controller.restoreExpense(e1, 1);
    expect(controller.expenses.value, hasLength(2));
  });

  test('kategori toplamları ve ay filtrelemesi doğru hesaplanır', () async {
    final oct1 = ExpenseModel(
      id: '1',
      amount: 10000,
      category: ExpenseCategory.market,
      date: DateTime(2026, 10, 1),
    );
    final oct2 = ExpenseModel(
      id: '2',
      amount: 15000,
      category: ExpenseCategory.market,
      date: DateTime(2026, 10, 5),
    );
    final oct3 = ExpenseModel(
      id: '3',
      amount: 8000,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 10, 8),
    );
    final nov1 = ExpenseModel(
      id: '4',
      amount: 20000,
      category: ExpenseCategory.bills,
      date: DateTime(2026, 11, 2),
    );

    await controller.addExpense(oct1);
    await controller.addExpense(oct2);
    await controller.addExpense(oct3);
    await controller.addExpense(nov1);

    expect(controller.totalForMonth(DateTime(2026, 10)), 33000);
    expect(controller.totalForMonth(DateTime(2026, 11)), 20000);

    final octTotals = controller.totalsByCategory(DateTime(2026, 10));
    expect(octTotals[ExpenseCategory.market], 25000);
    expect(octTotals[ExpenseCategory.transport], 8000);
    expect(octTotals[ExpenseCategory.bills], isNull);

    final octGrouped = controller.groupedByDate(DateTime(2026, 10));
    expect(octGrouped.keys, hasLength(3));
  });

  test('expensesForLast7Days 7 günlük harita üretir', () async {
    final now = DateTime(2026, 10, 23);
    final todayExpense = ExpenseModel(
      id: 'today',
      amount: 6000,
      category: ExpenseCategory.entertainment,
      date: now,
    );
    await controller.addExpense(todayExpense);

    final map = controller.expensesForLast7Days(now);
    expect(map, hasLength(7));
    expect(map[DateTime(2026, 10, 23)], 6000);
  });
}
