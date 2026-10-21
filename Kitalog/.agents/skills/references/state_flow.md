# State Yönetim ve Veri Akışı Kılavuzu (State Flow)

Bu kılavuz, **Kitalog** projesinde durum yönetimi (State Management), katmanlar arası veri akışı, kalıcı depolama ve reaktif güncelleme prensiplerini tanımlar. Bağlayıcı kurallar: [PROJECT.md](../../../PROJECT.md).

---

## 1. Temel Prensipler

1. **Harici Ağır Paket Yasağı:**  
   Bloc, Riverpod, Provider, GetX, MobX veya Redux gibi harici paketler kullanılmaz. Flutter çekirdek API'leri olan `ValueNotifier`, `ValueListenableBuilder` ve `InheritedWidget` esastır.
2. **Ağır setState Yasağı:**  
   Sayfa düzeyinde ve iş mantığı yönetiminde `setState` kullanılmaz. Sadece salt UI mikro-durumları (şifre göster/gizle, animasyon, seçili sekme gibi) için yerel `StatefulWidget` kabul edilir.
3. **Tek Yönlü Veri Akışı (Unidirectional Data Flow):**  
   Kullanıcı eylemi → Controller metodu → (Repository ile kalıcı kayıt) → State mutasyonu (`ValueNotifier.value`) → `ValueListenableBuilder` tetiklenmesi → Yalnızca ilgili widget ağacının yeniden çizilmesi.
4. **İmmutable Modeller:**  
   State nesneleri değiştirilemez (`@immutable`) olmalı; güncellemeler `copyWith` ile yeni nesne referansı üreterek tetiklenmelidir. Listeler için de yeni liste üretilir (`[...old, newItem]`); mevcut liste yerinde (`add`, `remove`) değiştirilmez, aksi halde `ValueNotifier` dinleyicileri tetiklenmez.
5. **Tek Doğruluk Kaynağı (Single Source of Truth):**  
   Kitap listesi, kullanıcı ve ayarlar uygulamada tek bir yerde (paylaşılan controller) tutulur. Ekranlar bu veriyi kopyalamaz, dinler.

---

## 2. Mimari Katmanlar ve Sorumluluklar

```text
[ View / Widget ] ──(1. Aksiyon: controller.updateCurrentPage())──► [ Controller ]
       ▲                                                                 │
       │                                                   (2. Kalıcı Kayıt) ▼
       │                                                          [ Repository ]
       │                                                                 │
       │                                                                 ▼
       │                                         [ LocalStorageService → SharedPreferences ]
       │                                                                 │
       │                                         (3. State Güncelleme)   ▼
       └──(4. Bildirim: ValueListenableBuilder dinler)── [ ValueNotifier<State> ]
```

### A. Model Katmanı
- Paylaşılan modeller: `lib/core/models/` (`BookModel`, `QuoteModel`, `NoteModel`, `UserModel`, `ReadingGoalModel`, `AppSettingsModel`, enum'lar).
- Ekrana özel UI state modelleri: `lib/features/<feature>/models/<feature>_model.dart`.
- `@immutable` anotasyonu taşır, tüm alanlar `final` tanımlanır.
- `copyWith`, `fromJson` ve `toJson` metotları eksiksiz uygulanır.
- Türetilebilen değerler (örn. `progress`, `isLent`) saklanmaz, getter olarak hesaplanır.

### B. Repository & Storage Katmanı (`lib/core/repositories/`, `lib/core/storage/`)
- `LocalStorageService`, `SharedPreferences` üzerinde tek erişim noktasıdır (JSON okuma/yazma, anahtarlar `storage_keys.dart` içinde).
- Repository'ler modelleri JSON'a çevirip saklar ve geri okur; UI veya `ValueNotifier` bilmez.
- Repository'ler asenkron (`Future`) API sunar; ileride gerçek veritabanına geçişte sadece bu katman değişir.

### C. Controller Katmanı
- **Paylaşılan Controller'lar** (`AuthController`, `LibraryController`, `SettingsController`): Uygulama açılışında `main.dart` içinde bir kez oluşturulur, `AppScope` ile ağaca verilir, uygulama boyunca yaşar.
- **Ekran Controller'ları** (`lib/features/<feature>/controllers/`): İlgili view oluşturur ve `dispose` eder.
- İş mantığını ve hesaplamaları içerir (ilerleme yüzdesi, yıllık hedef hesabı, filtreleme, validasyon sonucu).
- Durumu `ValueNotifier<T>` ile dışa açar.
- Flutter UI bağımlılığı içermez (yalnızca `foundation.dart`); `BuildContext` almaz.
- Bağımlılıklarını (repository vb.) constructor ile alır → testte fake verilebilir.
- Bellek sızıntısını önlemek için `dispose()` metodu sunar.

### D. View Katmanı (`views/<feature>_view.dart`)
- Ekran controller'ını oluşturur ve `dispose()` çağrısını garanti eder.
- Paylaşılan veriyi `AppScope.of(context)` üzerinden okur.
- Tüm sayfayı yeniden çizmek yerine hedef widget alanlarını `ValueListenableBuilder` ile sarar.
- 40 satırı aşan build parçalarını `widgets/` altındaki alt widget'lara böler.

### E. Widget Katmanı (`widgets/`, `lib/core/widgets/`)
- Mümkün olan her yerde `StatelessWidget` ve `const` constructor kullanır.
- Veriyi ve callback'leri parametre olarak alır; controller'a doğrudan bağımlı olmaz.
- Renkleri `Theme.of(context)` / `AppColors`, metinleri `context.l10n` üzerinden alır.

---

## 3. Uygulama Geneli State: `AppScope`

```dart
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.authController,
    required this.libraryController,
    required this.settingsController,
    required this.bookRepository,
    required this.goalRepository,
    required super.child,
  });

  final AuthController authController;
  final LibraryController libraryController;
  final SettingsController settingsController;
  final BookRepository bookRepository;
  final GoalRepository goalRepository;
  // Diğer repository'ler (Quote, Note, Auth, Settings) aynı şekilde eklenir.

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ağaçta bulunamadı.');
    return scope!;
  }

  // Controller referansları sabit; değişiklikler ValueNotifier ile yayılır.
  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
```

**Tema ve Dil Akışı:** `SettingsController.state` (`ValueNotifier<AppSettingsModel>`) `MaterialApp`'i saran bir `ValueListenableBuilder` tarafından dinlenir. Ayarlar ekranında tema/dil değiştiğinde önce repository'ye yazılır, sonra state güncellenir ve uygulama anında yeniden çizilir.

```dart
ValueListenableBuilder<AppSettingsModel>(
  valueListenable: AppScope.of(context).settingsController.state,
  builder: (context, settings, _) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: Locale(settings.localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  },
);
```

**Oturum Akışı:** Splash ekranı `AuthController.restoreSession()` sonucuna göre `AppRoutes.home` veya `AppRoutes.register` rotasına `pushReplacementNamed` ile yönlendirir. Çıkışta oturum anahtarı silinir, veriler korunur.

---

## 4. Yaşam Döngüsü (Lifecycle) Standardı

```dart
class _ReadingGoalViewState extends State<ReadingGoalView> {
  ReadingGoalController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. Controller bir kez başlatılır (AppScope InheritedWidget olduğu için burada okunur)
    _controller ??= ReadingGoalController(
      library: AppScope.of(context).libraryController,
      repository: AppScope.of(context).goalRepository,
    )..load();
  }

  @override
  void dispose() {
    // 2. Bellek sızıntısını önlemek için yalnızca bu view'ın sahibi olduğu controller dispose edilir.
    //    Paylaşılan (AppScope) controller'lar burada dispose EDİLMEZ.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReadingGoalState>(
      valueListenable: _controller!.state,
      builder: (context, state, _) {
        // 3. Yalnızca bu blok reaktif olarak yeniden çizilir
        return GoalProgressWidget(
          finished: state.finishedCount,
          target: state.targetBookCount,
        );
      },
    );
  }
}
```

- Ekran controller'ı paylaşılan bir notifier'ı dinliyorsa (`library.books.addListener(_recalculate)`), kendi `dispose()` metodunda `removeListener` çağırmak zorundadır.
- `TextEditingController`, `FocusNode`, `TabController` gibi Flutter nesneleri view'ın `State`'inde oluşturulur ve orada dispose edilir.

---

## 5. Hata ve Yan Etki Yönetimi

- Asenkron işlemlerde (Open Library araması, depolama okuma/yazma) state modeli `ViewStatus` (`initial`, `loading`, `success`, `failure`) ve gerekirse `errorKey` barındırır.
- UI katmanında try-catch ile karmaşık logic yazılmaz; hata controller içinde yakalanır ve state'e yansıtılır.
- Hata mesajları state'e metin olarak değil, çoklu dil anahtarı/enum olarak yazılır (örn. `AddBookError.notFound`, `AddBookError.network`); view bunu `context.l10n` ile çevirir.
- İnternet yokken kapak resimleri ve arama düzgün bozulmalıdır: `BookCoverImage` yer tutucu gösterir, arama ekranı "manuel ekle" seçeneğine yönlendirir.
- SnackBar veya Dialog gösterimleri `builder` içinde yapılmaz; view içinde `state.addListener` kancası ile ve `mounted` kontrolüyle tetiklenir.

---

## 6. Test Edilebilirlik

- Controller'lar repository'leri constructor ile aldığı için testlerde fake repository (`test/fakes/`) verilir; `SharedPreferences` için `SharedPreferences.setMockInitialValues({})` kullanılır.
- Her controller için: başlangıç state'i, her public metodun state'e etkisi ve sınır durumları (örn. sayfa sayısı 0-`pageCount` aralığında, hedef 0 iken ilerleme 0) test edilir.
- Validator'lar (`validators.dart`) saf fonksiyonlardır ve tablo bazlı birim testlerle doğrulanır.
