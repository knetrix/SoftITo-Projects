# State Management with ValueNotifier

Veri Akışı: **View → Controller Metodu → `ValueNotifier.value` (Yeni Immutable Nesne) → `LocalStorageService` (Kalıcılık) → `ValueListenableBuilder` Yeniden Çizer.**

## 1. LocalStorageService (Tek Depolama Kapısı)

```dart
// lib/core/services/local_storage_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  bool get isLoggedIn => _prefs.getBool(StorageKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(StorageKeys.isLoggedIn, value);

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));
}
```

```dart
// lib/core/constants/storage_keys.dart
abstract final class StorageKeys {
  static const String user = 'user';
  static const String isLoggedIn = 'is_logged_in';
  static const String appSettings = 'app_settings';
  static const String activeChallenge = 'active_challenge';
  static const String goals = 'goals';
  static const String expenses = 'expenses';
  static const String budgets = 'budgets';
}
```

## 2. Immutable Model (Kuruş Bazlı Para)

```dart
// lib/features/expenses/models/expense_model.dart
import 'package:flutter/foundation.dart';

enum ExpenseCategory { market, transport, bills, entertainment, health, education, other }

@immutable
class ExpenseModel {
  final String id;
  final int amount; // kuruş: 125,50 TL -> 12550
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  ExpenseModel copyWith({
    String? id,
    int? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      category: ExpenseCategory.values.asNameMap()[json['category']] ??
          ExpenseCategory.other,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
```

## 3. Controller (İş Mantığı + Kalıcılık)

```dart
// lib/features/expenses/controllers/expenses_controller.dart
import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/expense_model.dart';

class ExpensesController {
  final LocalStorageService _storage;
  final ValueNotifier<List<ExpenseModel>> expenses;

  ExpensesController(this._storage)
      : expenses = ValueNotifier<List<ExpenseModel>>(
          _storage
              .readJsonList(StorageKeys.expenses)
              .map(ExpenseModel.fromJson)
              .toList(),
        );

  /// Seçilen ayın toplam harcaması (kuruş)
  int totalForMonth(DateTime month) => expenses.value
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .fold(0, (sum, e) => sum + e.amount);

  /// Kategori -> toplam (kuruş); grafik ve lejant için
  Map<ExpenseCategory, int> totalsByCategory(DateTime month) {
    final result = <ExpenseCategory, int>{};
    for (final e in expenses.value) {
      if (e.date.year != month.year || e.date.month != month.month) continue;
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    // Mutasyon yok: yeni liste referansı -> dinleyiciler tetiklenir
    expenses.value = [expense, ...expenses.value];
    await _persist();
  }

  Future<void> removeExpense(String id) async {
    expenses.value = expenses.value.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> _persist() => _storage.writeJsonList(
        StorageKeys.expenses,
        expenses.value.map((e) => e.toJson()).toList(),
      );

  void dispose() {
    expenses.dispose();
  }
}
```

## 4. Formdan Gelen Tutarı Kuruşa Çevirme

```dart
// lib/core/extensions/money_extensions.dart
import 'package:intl/intl.dart';

extension MoneyParsing on String {
  /// "1.250,50" -> 125050, "1250,5" -> 125050, "1250.5" -> 125050 ; geçersizse null
  /// Virgül varsa TR formatı kabul edilir (nokta = binlik ayırıcı).
  int? toKurus() {
    final input = trim();
    final normalized = input.contains(',')
        ? input.replaceAll('.', '').replaceAll(',', '.')
        : input;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }
}

extension MoneyFormatting on int {
  /// 125050 -> "₺1.250,50" (tr) / "₺1,250.50" (en)
  String toCurrency(String localeCode) =>
      NumberFormat.currency(locale: localeCode, symbol: '₺').format(this / 100);
}
```

> `double` Sadece Parse / Format Sınırında Kullanılır; Toplama, Çıkarma, Karşılaştırma Daima `int` Kuruş ile Yapılır.

## 5. Türetilmiş Değerler Saklanmaz

```dart
// GoalModel içinde
int get savedAmount => steps.fold(0, (sum, s) => sum + s.amount);
double get progress =>
    targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);
bool get isReached => savedAmount >= targetAmount;
```

`savedAmount`, `progress`, Kalan Bütçe, Streak Durumu Gibi Hesaplanabilen Değerler JSON'a Yazılmaz; Getter veya Controller Metodu Olarak Hesaplanır.
