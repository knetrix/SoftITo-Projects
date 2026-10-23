# State Yönetim ve Veri Akışı Kılavuzu (State Flow)

Bu kılavuz, **Money Habit Tracker** projesinde durum yönetimi (State Management), katmanlar arası veri akışı, yerel kalıcılık ve reaktif güncelleme prensiplerini tanımlar.

---

## 1. Temel Prensipler

1. **Harici Ağır Paket Yasağı:**  
   Provider, Bloc, Riverpod, GetX, MobX veya Redux gibi harici paketler kullanılmaz. Flutter çekirdek API'si olan `ValueNotifier` ve `ValueListenableBuilder` esastır.
2. **Ağır setState Yasağı:**  
   Sayfa düzeyinde ve iş mantığı yönetiminde `setState` kullanılmaz. Sadece salt UI mikro-durumları (şifre göster/gizle, buton animasyonu, seçili sekme) için yerel `StatefulWidget` kabul edilir.
3. **Tek Yönlü Veri Akışı (Unidirectional Data Flow):**  
   Kullanıcı eylemi -> Controller metodu -> State mutasyonu (`ValueNotifier.value = yeniNesne`) -> `LocalStorageService` ile kalıcılık -> `ValueListenableBuilder` tetiklenmesi -> Yalnızca ilgili widget ağacının yeniden çizilmesi.
4. **İmmutable Modeller:**  
   State nesneleri değiştirilemez (`@immutable`) olmalı; güncellemeler `copyWith` veya yeni liste referansı üreterek tetiklenmelidir. `list.add(...)` ile mevcut listeyi değiştirmek dinleyicileri **tetiklemez** ve yasaktır.
5. **Kuruş Bazlı Para:**  
   Tüm tutarlar `int` kuruş olarak tutulur ve hesaplanır; `double` yalnızca form parse ve ekran formatlama sınırında kullanılır.

---

## 2. Mimari Katmanlar ve Sorumluluklar

```text
[ View / Widget ] --(1. Aksiyon: controller.addExpense(e))--> [ Controller ] --(3. Kalıcılık)--> [ LocalStorageService ]
       ^                                                             |                                   |
       |                                                             | (2. State Güncelleme)        SharedPreferences
       |                                                             v
       +----(4. Bildirim: ValueListenableBuilder dinler)---- [ ValueNotifier<Model / List<Model>> ]
```

### A. Model Katmanı (`models/<feature>_model.dart`)
- `@immutable` anotasyonu taşır, tüm alanlar `final`.
- `copyWith`, `fromJson` ve `toJson` metotları eksiksiz uygulanır.
- Enum'lar JSON'a `name` ile yazılır, `values.asNameMap()` ile okunur (bilinmeyen değerde güvenli varsayılan).
- Türetilmiş değerler (`savedAmount`, `progress`, `isCompleted`) getter'dır, JSON'a yazılmaz.

### B. Controller Katmanı (`controllers/<feature>_controller.dart`)
- İş mantığını ve hesaplamaları içerir (bütçe kalanı, kategori toplamı, streak, hedef yüzdesi).
- Durumu `ValueNotifier<T>` ile dışa açar.
- `LocalStorageService`'i constructor ile alır (test edilebilirlik için); `SharedPreferences`'a doğrudan erişmez.
- Flutter UI bağımlılığı taşımaz (yalnızca `foundation.dart`); `BuildContext` almaz, l10n metni üretmez.
- Bellek sızıntısını önlemek için `dispose()` metodu sunar.

### C. View Katmanı (`views/<feature>_view.dart`)
- Controller'ı `initState`'te başlatır, `dispose()` çağrısını garanti eder.
- Tüm sayfayı `setState` ile yeniden çizmek yerine hedef alanları `ValueListenableBuilder` ile sarar.
- 40 satırı aşan build parçalarını `widgets/` altındaki alt widget'lara böler.
- Ana sekmelerde AppBar'a `SettingsActionButton` ekler.

### D. Widget Katmanı (`widgets/<feature>_<parça>.dart`)
- Mümkün olan her yerde `StatelessWidget` ve `const` constructor kullanır.
- Veriyi parametre, aksiyonu callback ile alır; controller'a doğrudan bağlanmaz.
- Renk ve stil için `Theme.of(context)` / `AppColors`, metin için `context.l10n` kullanır.

---

## 3. Yaşam Döngüsü (Lifecycle) Standardı

```dart
class _GoalsViewState extends State<GoalsView> {
  late final GoalsController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Controller başlatma (kalıcı veriler storage'dan yüklenir)
    _controller = GoalsController(widget.storage);
  }

  @override
  void dispose() {
    // 2. Bellek sızıntısını önlemek için notifier dispose edilir
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GoalModel>>(
      valueListenable: _controller.goals,
      builder: (context, goals, child) {
        // 3. Yalnızca bu blok reaktif olarak yeniden çizilir
        return GoalList(goals: goals, onAddStep: _controller.addStep);
      },
    );
  }
}
```

---

## 4. Feature'lar Arası Veri Paylaşımı

- **Global durumlar** (tema, dil → `SettingsController`; oturum → `AuthController`) `app.dart` seviyesinde bir kez oluşturulur ve gerektiği yere parametre ile geçirilir.
- **Ana Panel (`dashboard`)** kendi verisini tutmaz; `ExpensesController`, `BudgetController`, `GoalsController`, `ChallengeController` değerlerini okur. Bu controller'lar `HomeShellView` içinde bir kez oluşturulup sekmelere paylaştırılır; böylece bir sekmede eklenen harcama Panel'e anında yansır.
- Birden fazla notifier'ı aynı anda dinlemek için `Listenable.merge([...])` + `ListenableBuilder` kullanılır.

---

## 5. Hata ve Yan Etki Yönetimi

- Asenkron işlemlerde (kayıt, giriş, profil resmi seçme) durum modeli `status` alanı barındırır: `initial`, `loading`, `success`, `failure`.
- Hata metni değil **hata anahtarı** (enum) state'e yazılır; View bunu `context.l10n` ile çevirir.
- UI katmanında doğrudan try-catch blokları ile karmaşık logic yazılmaz; hata durumu controller state'ine yansıtılır.
- SnackBar veya Dialog gösterimleri (örn: harcama silindi → Geri Al, challenge tamamlandı → tebrik) `addListener` kancaları veya aksiyon sonrası dönen sonuçla, `mounted` kontrolünden sonra yapılır.
