# State Yönetim ve Veri Akışı Kılavuzu (State Flow)

Bu kılavuz, **Rutino** projesinde durum yönetimi (State Management), katmanlar arası tek yönlü veri akışı ve reaktif güncelleme prensiplerini tanımlar.

---

## 1. Temel Prensipler

1. **Harici Ağır Paket Yasağı:**  
   Bloc, Riverpod, MobX veya Redux gibi harici ağır paketler kullanılmaz. Flutter çekirdek API'si olan `ValueNotifier` ve `ValueListenableBuilder` esastır.
2. **Ağır setState Yasağı:**  
   Sayfa düzeyinde ve iş mantığı yönetiminde `setState` kullanılmaz. Sadece salt UI animasyon veya mikro-durumlar için yerel `StatefulWidget` kabul edilir.
3. **Tek Yönlü Veri Akışı (Unidirectional Data Flow):**  
   Kullanıcı eylemi -> Controller metodu -> State mutasyonu (`ValueNotifier.value`) -> `ValueListenableBuilder` tetiklenmesi -> Yalnızca ilgili widget ağacının yeniden çizilmesi.
4. **İmmutable Modeller:**  
   State nesneleri değiştirilemez (`@immutable`) olmalı; güncellemeler `copyWith` üzerinden yeni nesne referansı üreterek tetiklenmelidir.

---

## 2. Mimari Katmanlar ve Sorumluluklar

```text
[ View / Widget ]  ---(1. Kullanıcı Aksiyonu: controller.toggleHabit(id))---> [ Controller ]
       ^                                                                               |
       |                                                                               | (2. State Güncelleme)
       |                                                                               v
       +---(3. Bildirim: ValueListenableBuilder dinler)--- [ ValueNotifier<HabitState> ]
```

### A. Model Katmanı (`models/<feature>_model.dart`)
- `@immutable` anotasyonu taşır.
- Tüm alanlar `final` tanımlanır.
- `copyWith`, `fromJson` ve `toJson` metotları eksiksiz uygulanır.

### B. Controller Katmanı (`controllers/<feature>_controller.dart`)
- İş mantığını (business logic), seri/puan hesaplamalarını ve veri servis çağrılarını içerir.
- Durumu `ValueNotifier<T>` ile dışa açar.
- View katmanına doğrudan Flutter UI bağımlılığı sokmaz (yalnızca `foundation.dart`).
- Yaşam döngüsü bitiminde bellek sızıntısını önlemek için `dispose()` metodu sunar.

### C. View Katmanı (`views/<feature>_view.dart`)
- Controller'ı başlatır ve `dispose()` çağrısını garanti eder.
- Tüm sayfayı `setState` ile yeniden çizmek yerine hedef widget alanlarını `ValueListenableBuilder` ile sarar.
- 40 satırı aşan build parçalarını `widgets/` altındaki alt widget'lara böler.

### D. Widget Katmanı (`widgets/<feature>_widget.dart`)
- Mümkün olan her yerde `StatelessWidget` ve `const` constructor kullanır.
- Renk ve stil değerlerini tema dosyalarından (`Theme.of(context)`) ve sabitlerden alır.

---

## 3. Yaşam Döngüsü (Lifecycle) Standardı

```dart
class _HabitsViewState extends State<HabitsView> {
  late final HabitsController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Controller başlatma
    _controller = HabitsController();
    _controller.loadHabits();
  }

  @override
  void dispose() {
    // 2. Bellek sızıntısını önlemek için notifier dispose edilir
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutino - Alışkanlıklar')),
      body: ValueListenableBuilder<HabitsState>(
        valueListenable: _controller.state,
        builder: (context, state, child) {
          // 3. Yalnızca bu blok reaktif olarak yeniden çizilir
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return HabitListWidget(
            habits: state.habits,
            onToggle: _controller.toggleHabit,
          );
        },
      ),
    );
  }
}
```

---

## 4. Hata ve Asenkron Durum Yönetimi

- Asenkron veri çekme ve AI entegrasyonu işlemlerinde durum modeli şu yaşam döngüsünü takip eder:
  - `status`: `initial`, `loading`, `success`, `failure`
- UI katmanında doğrudan karmaşık `try-catch` blokları yazılmaz; hata durumu controller state'ine (veya hata mesajı alanına) yansıtılır.
- SnackBar, Toast veya Dialog gösterimleri için listenable listener kancaları kullanılır.
