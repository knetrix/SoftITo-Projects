---
name: flutter-feature-scaffold
description: Money Habit Tracker Flutter projesinde yeni bir feature (ekran / işlev modülü) açarken lib/features/<feature_name> altında controllers, models, views, widgets klasör yapısını ve test/features altında birim test iskeletini oluşturur. ValueNotifier state mimarisini, LocalStorageService kalıcılığını, kuruş bazlı para modelini ve l10n başlık anahtarını standartlara uygun üretir.
---

# Flutter Feature Scaffold (Modüler Ekran İskeleti)

Bu Yetenek, Projede Yeni Bir Ekran ya da İşlev Modülü Açarken `PROJECT_NEW.md` Kurallarına (Feature-First Mimari, ValueNotifier, Const, l10n, Kuruş Bazlı Para) Tam Uyulmasını Garanti Altına Alır.

**Projede Planlanan Feature'lar:** `auth`, `home`, `dashboard`, `challenge`, `goals`, `expenses`, `budget`, `settings`

## Temel Kurallar

### Asla Tek Dosyada Toplama

UI (`views/<feature>_view.dart`), State Controller (`controllers/<feature>_controller.dart`), Model (`models/<feature>_model.dart`) ve Alt Widget'lar (`widgets/`) Ayrı Dosyalarda Açılmalıdır.

### State Management

Durum Controller İçindeki `ValueNotifier` ile Tutulur, View `ValueListenableBuilder` ile Dinler. Sayfa Düzeyinde `setState` ve Devasa StatefulWidget'lar YASAKTIR. Harici State Paketi Kullanılmaz.

### Kalıcılık

Controller, `LocalStorageService`'i Constructor ile Alır. View / Widget Asla `SharedPreferences`'a Doğrudan Erişmez.

### Const ve Tema Zorunluluğu

Mümkün Olan Tüm Widget'larda `const` Olmalıdır. Renk / Stil `Theme.of(context)` ve `AppColors`'tan, Metinler `context.l10n`'dan Alınır.

### Para

Tutarlar `int` Kuruş Olarak Tutulur. `double` ile Para Hesabı YASAKTIR.

## Adım Adım Uygulama Akışı

### Adım 0: Ön Koşullar

Script'in Ürettiği Kod Aşağıdaki Çekirdek Dosyalara Bağımlıdır; Yoksa Önce Bunlar Oluşturulmalıdır (Bkz. `flutter-development` Skill'i):

- `lib/core/services/local_storage_service.dart`
- `lib/core/extensions/context_extensions.dart` (`context.l10n`, `context.colors`, `context.textStyles`)
- `lib/core/extensions/money_extensions.dart` (`int.toCurrency`, `String.toKurus`)
- `lib/core/widgets/settings_action_button.dart`
- `lib/core/l10n/app_tr.arb`, `lib/core/l10n/app_en.arb`

### Adım 1: Script ile İskeleti Üret

Proje Kök Dizininde Çalıştır:

```bash
bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh <feature_name>
```

Script Şunları Yapar:

- Feature Adını snake_case Olarak Doğrular, Var Olan Dolu Bir Feature Klasörünün **Üzerine Yazmaz**.
- Aşağıdaki Yapıyı Kurar:

```text
lib/features/<feature_name>/
    controllers/
        <feature_name>_controller.dart
    models/
        <feature_name>_model.dart
    views/
        <feature_name>_view.dart
    widgets/
        <feature_name>_card.dart
test/features/<feature_name>/
    <feature_name>_controller_test.dart
```

- ARB Dosyaları Varsa `<featureName>Title` l10n Anahtarını TR ve EN Dosyalarına Ekler.

### Adım 2: Model Dosyasını Feature'a Göre Düzenle

`models/<feature_name>_model.dart` `@immutable` Olmalı; `copyWith`, `fromJson`, `toJson` İçermelidir. Alanlar `PROJECT_NEW.md` 6.3 Veri Modeli Tablosuna Göre Düzenlenir. Örnek (`expenses`):

```dart
import 'package:flutter/foundation.dart';

enum ExpenseCategory { market, transport, bills, entertainment, health, education, other }

@immutable
class ExpenseModel {
  final String id;
  final int amount; // kuruş
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

### Adım 3: Controller Mantığını Yaz

`controllers/<feature_name>_controller.dart` İçinde `ValueNotifier` Tanımları ve İş Mantığı Yer Alır. Storage Anahtarı `core/constants/storage_keys.dart`'a Taşınır. Örnek (`challenge` Streak Mantığı):

```dart
import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/challenge_model.dart';

class ChallengeController {
  final LocalStorageService _storage;
  final ValueNotifier<ChallengeModel?> state;

  ChallengeController(this._storage)
      : state = ValueNotifier<ChallengeModel?>(
          _loadChallenge(_storage),
        );

  static ChallengeModel? _loadChallenge(LocalStorageService storage) {
    final json = storage.readJson(StorageKeys.activeChallenge);
    return json == null ? null : ChallengeModel.fromJson(json);
  }

  /// Bugün challenge'ın kaçıncı günü (1-10); aralık dışındaysa null
  int? todayDayNumber(DateTime now) {
    final challenge = state.value;
    if (challenge == null) return null;
    final start = _dateOnly(challenge.startDate);
    final day = _dateOnly(now).difference(start).inDays + 1;
    return (day >= 1 && day <= challenge.tasks.length) ? day : null;
  }

  Future<void> completeToday(DateTime now) async {
    final challenge = state.value;
    final day = todayDayNumber(now);
    if (challenge == null || day == null) return;
    if (challenge.tasks[day - 1].isCompleted) return;

    final previousDone = day > 1 && challenge.tasks[day - 2].isCompleted;
    final streak = previousDone ? challenge.currentStreak + 1 : 1;
    final tasks = [
      for (final t in challenge.tasks)
        t.dayNumber == day ? t.copyWith(completedAt: now) : t,
    ];

    state.value = challenge.copyWith(
      tasks: tasks,
      currentStreak: streak,
      bestStreak: streak > challenge.bestStreak ? streak : challenge.bestStreak,
      isCompleted: day == challenge.tasks.length,
    );
    await _storage.writeJson(StorageKeys.activeChallenge, state.value!.toJson());
  }

  // Saat bilgisini atar; gerçek projede core/extensions/date_extensions.dart'a taşınır
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void dispose() {
    state.dispose();
  }
}
```

> Not: `DateUtils.dateOnly` `material.dart` İçinde Olduğu için Controller'da Kullanılmaz (Controller UI Bağımlılığı Taşımaz).

### Adım 4: View Dosyasını Tamamla

`views/<feature_name>_view.dart`, Controller'ın Yaşam Döngüsünü Yöneten `StatefulWidget`'tır (`initState` → Oluştur, `dispose` → Kapat). Sadece `ValueListenableBuilder` ile Saran Alanlar Yeniden Çizilir. Ana Sekmelerde AppBar'a `SettingsActionButton` Eklenir. Tam Örnek: [examples/sample_screen.dart](examples/sample_screen.dart)

### Adım 5: Widget Dosyalarını Böl

`widgets/` Altındaki Her Parça `const` Constructor'lı `StatelessWidget`'tır; Veriyi Parametre, Aksiyonu Callback ile Alır:

```dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/expense_model.dart';

class ExpenseCategoryChip extends StatelessWidget {
  final ExpenseCategory category;

  const ExpenseCategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(category.icon, size: 16, color: AppColors.forCategory(category)),
      label: Text(category.label(context.l10n)),
      side: BorderSide(color: AppColors.forCategory(category)),
    );
  }
}
```

### Adım 6: Testleri Tamamla ve Doğrula

- Üretilen `test/features/<feature_name>/<feature_name>_controller_test.dart` Dosyasına Feature'a Özel Hesap Testleri Eklenir (Örn: Kalan Bütçe, Kategori Toplamı, Streak Sıfırlanması, Hedef Yüzdesi %100'de Sabitlenmesi).
- Ardından:

```bash
flutter gen-l10n
flutter analyze
flutter test
```

### Adım 7: Clean Architecture Kurallarına Uyum

- **Separation of Concerns:** Her Dosyanın Tek Bir Sorumluluğu Olduğundan Emin Ol.
- **Reusability:** Birden Fazla Feature'da Kullanılan Widget'ları `core/widgets/` Altına Taşı.
- **Testability:** Controller'lar `BuildContext` Almaz, Storage'ı Constructor ile Alır; Böylece Mock `SharedPreferences` ile Test Edilir.

## Kullanım Örnekleri

### Örnek 1: Yeni Feature'ı Ana Kabuğa Sekme Olarak Bağlama

```dart
// lib/features/home/views/home_shell_view.dart (parça)
IndexedStack(
  index: selectedIndex,
  children: [
    DashboardView(storage: widget.storage),
    ChallengeView(storage: widget.storage),
    GoalsView(storage: widget.storage),
    ExpensesView(storage: widget.storage),
    BudgetView(storage: widget.storage),
  ],
)
```

### Örnek 2: Feature'ı Ayrı Rota Olarak Bağlama

```dart
// lib/core/router/app_router.dart (parça)
AppRoutes.settings => SettingsView(
    storage: storage,
    settingsController: settingsController,
  ),
```

## Ekstra İpuçları

- **Dependency Injection:** Harici DI Paketi (GetIt, Provider) KULLANILMAZ; Bağımlılıklar Constructor Parametresi ile Geçirilir. Paylaşılan Controller'lar `HomeShellView` veya `app.dart`'ta Bir Kez Oluşturulur.
- **Navigation:** Çekirdek `Navigator` + `AppRouter.onGenerateRoute` Kullanılır; go_router Eklenmez.
- **Form Ekranları:** Ekle / Düzenle Formları Tercihen `showModalBottomSheet` ile Açılır.
- **Testing:** Her Controller için Ayrı Birim Testi, Kritik Formlar için Widget Testi Yaz.

## SSS

### Soru: Hangi durumlarda bu yeteneği kullanmalıyım?
**Cevap:** Yeni Bir Ekran veya İşlev Modülü (Örn: `expenses`, `goals`, `challenge`) Oluştururken Bu Yeteneği Kullanmalısın.

### Soru: Hangi durumlarda bu yeteneği kullanmamalıyım?
**Cevap:** Mevcut Bir Ekranı Güncellerken veya Küçük Bir Hata Düzeltmesi Yaparken Bu Yeteneği Kullanmamalısın; Bunun için `flutter-development` Skill'i Yeterlidir.
