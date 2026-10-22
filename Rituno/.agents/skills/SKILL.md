name:flutter-feature-scaffold
description: Rutino Flutter projesinde feature bazlı modüler kod geliştirmek için gerekli klasör yapısını oluşturur. ValueNotifier state mimarisini, Clean UI ayrımını, 40 satır alt-widget kuralını ve immutable modelleri standartlara uygun olarak üretir.

# Flutter Feature Scaffold (Rutino Modüler Ekran İskeleti)
Bu yetenek, Rutino projesinde yeni bir ekran ya da işlev modülü açarken Clean UI ve reaktif state kurallarına tam uyulmasını garanti altına alır.

## Temel Kurallar

### 1. Asla Tek Dosyada Toplama
UI (`views/<feature>_view.dart`), State Controller (`controllers/<feature>_controller.dart`), Model (`models/<feature>_model.dart`) ve Alt Bileşenler (`widgets/<feature>_widget.dart`) dosyaları ayrı ayrı açılmalıdır.

### 2. State Management (ValueNotifier Zorunluluğu)
- Harici ağır state paketleri (Bloc, Riverpod, MobX vb.) kullanılmaz.
- Sayfa düzeyinde ağır `setState` yasaktır.
- Reaktif ve hafif durum yönetimi için doğrudan Flutter çekirdeğindeki `ValueNotifier` ve `ValueListenableBuilder` kullanılır.

### 3. Const Zorunluluğu
Mümkün olan tüm statik widget'larda `const` zorunludur.

### 4. 40 Satır Kuralı ve Modüler UI
40 satırı geçen `build` metotları kesinlikle `widgets/` klasörü altında alt widget'lara parçalanmalıdır.

---

## Adım Adım Uygulama Akışı

### Adım 1: Klasör Yapısı Oluşturma
Hedeflenen modül adlarını (Örn: `habits`, `statistics`, `community`), `lib/features/<feature_name>` altına kur:

```text
lib/features/<feature_name>/
├── controllers/
│   └── <feature_name>_controller.dart
├── models/
│   └── <feature_name>_model.dart
├── views/
│   └── <feature_name>_view.dart
└── widgets/
    └── <feature_name>_widget.dart
```

### Adım 2: Model Dosyasını Oluşturma (`models/<feature_name>_model.dart`)
İmmutable (`@immutable`) ve `copyWith`, `fromJson`, `toJson` metotlarına sahip olmalıdır:

```dart
import 'package:flutter/foundation.dart';

@immutable
class HabitModel {
  final String id;
  final String title;
  final String description;
  final int streakCount;
  final bool isCompletedToday;

  const HabitModel({
    required this.id,
    required this.title,
    this.description = '',
    this.streakCount = 0,
    this.isCompletedToday = false,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    int? streakCount,
    bool? isCompletedToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      streakCount: streakCount ?? this.streakCount,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      streakCount: json['streakCount'] as int? ?? 0,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'streakCount': streakCount,
      'isCompletedToday': isCompletedToday,
    };
  }
}
```

### Adım 3: Controller Dosyasını Yazma (`controllers/<feature_name>_controller.dart`)
İş mantığını barındırır, `ValueNotifier` ile durumu dışa açar ve bellek sızıntısını önlemek için `dispose()` sunar:

```dart
import 'package:flutter/foundation.dart';
import '../models/habits_model.dart';

class HabitsController {
  final ValueNotifier<List<HabitModel>> habitsNotifier =
      ValueNotifier<List<HabitModel>>(<HabitModel>[]);

  void addHabit(HabitModel newHabit) {
    habitsNotifier.value = [...habitsNotifier.value, newHabit];
  }

  void toggleHabitCompletion(String habitId) {
    habitsNotifier.value = habitsNotifier.value.map((habit) {
      if (habit.id == habitId) {
        final bool willComplete = !habit.isCompletedToday;
        return habit.copyWith(
          isCompletedToday: willComplete,
          streakCount: willComplete ? habit.streakCount + 1 : (habit.streakCount > 0 ? habit.streakCount - 1 : 0),
        );
      }
      return habit;
    }).toList();
  }

  void dispose() {
    habitsNotifier.dispose();
  }
}
```

### Adım 4: Alt Widget Dosyalarını Oluşturma (`widgets/<feature_name>_widget.dart`)
StatelessWidget ve `const` constructor kullanır; 40 satır kuralına sadık kalır:

```dart
import 'package:flutter/material.dart';
import '../models/habits_model.dart';

class HabitCardWidget extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.local_fire_department,
          color: habit.streakCount > 0 ? Colors.orangeAccent : Colors.grey,
        ),
        title: Text(
          habit.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('Seri: ${habit.streakCount} gün'),
        trailing: IconButton(
          icon: Icon(
            habit.isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habit.isCompletedToday ? Colors.greenAccent : null,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
```

### Adım 5: View Dosyasını Oluşturma (`views/<feature_name>_view.dart`)
Controller yaşam döngüsünü yönetir, sayfayı komple yeniden çizmek yerine `ValueListenableBuilder` ile ilgili bölümleri dinler:

```dart
import 'package:flutter/material.dart';
import '../controllers/habits_controller.dart';
import '../models/habits_model.dart';
import '../widgets/habits_widget.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  late final HabitsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HabitsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlıklarım'),
      ),
      body: ValueListenableBuilder<List<HabitModel>>(
        valueListenable: _controller.habitsNotifier,
        builder: (context, habits, _) {
          if (habits.isEmpty) {
            return const Center(child: Text('Henüz alışkanlık eklenmedi.'));
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitCardWidget(
                habit: habit,
                onToggle: () => _controller.toggleHabitCompletion(habit.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## Clean Architecture Kurallarına Uyum
- **Separation of Concerns:** Her katman kendi sorumluluğuna odaklanır. Model veri yapısını, Controller iş kurallarını ve reaktif state'i, View ve Widget ise arayüzü sunar.
- **Reusability:** Alt widget'lar ve iş mantığı diğer modüllerde kolayca yeniden kullanılabilir şekilde tasarlanır.
- **Testability:** Controller katmanı UI bağımsız olduğundan saf Dart birim testleriyle hızla test edilebilir.

---

## Ekstra İpuçları
- **Bağımlılık Yönetimi (DI):** Gerekli durumlarda servisler (örn: `StorageService`, `AIService`) constructor enjeksiyonu veya hafif servis sağlayıcılar üzerinden verilir.
- **Navigasyon:** Flutter standart Route mekanizmaları veya deklaratif yapı tercih edilir.
- **Doğrulama:** Yeni bir modül yazdıktan sonra mutlaka `flutter analyze` ve `flutter test` çalıştırılmalıdır.
