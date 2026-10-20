# Tiknow - State Yönetim ve Veri Akışı Kılavuzu (State Flow)

Bu kılavuz, **Tiknow** araç kiralama projesinde durum yönetimi (State Management), katmanlar arası veri akışı, kalıcılık, çoklu dil/tema ve CustomPainter harita entegrasyonu prensiplerini tanımlar.

---

## 1. Temel Prensipler

1. **Harici Ağır Paket Yasağı:**  
   Bloc, Riverpod, MobX, Redux, GetX, Provider gibi paketler kullanılmaz. Flutter çekirdek API'si olan `ValueNotifier` ve `ValueListenableBuilder` esastır.
2. **Ağır setState Yasağı:**  
   Sayfa düzeyinde ve iş mantığı yönetiminde `setState` kullanılmaz. Sadece salt UI animasyon veya mikro-durumlar (form alanı, `TextEditingController`) için yerel `StatefulWidget` kabul edilir.
3. **Tek Yönlü Veri Akışı (Unidirectional Data Flow):**  
   Kullanıcı eylemi -> Controller metodu -> State mutasyonu (`ValueNotifier.value`) -> (varsa `StorageService` ile kalıcılık) -> `ValueListenableBuilder` tetiklenmesi -> Yalnızca ilgili widget ağacının ve CustomPainter'ın yeniden çizilmesi.
4. **İmmutable Modeller:**  
   State nesneleri `@immutable` olmalı; güncellemeler `copyWith` ile yeni referans üretir.
5. **Özel Harita/Grafik Çizimi (CustomPainter):**  
   İstanbul haritası, araç marker'ları ve kullanım çubukları harici kütüphanesiz `CustomPainter` ile çizilir; veri Controller'dan painter'a parametre olarak geçer.
6. **Kalıcılık Tek Kapıdan:**  
   `shared_preferences` yalnızca `core/services/storage_service.dart` içinde kullanılır. Controller'lar `StorageService`'e bağımlıdır, View'lar değildir.

---

## 2. Mimari Katmanlar ve Sorumluluklar

```text
[ View / Widget ] --(1. Aksiyon: controller.startRental())--> [ Controller ]
       ^                                                         |  (2. State güncelle)
       |                                                         v
       +--(3. ValueListenableBuilder dinler)-- [ ValueNotifier<Model> ]
       |                                                         |
       +--> [ CustomPainter (Harita / Marker / Bar) ]            +--(4. persist)--> [ StorageService ]
```

### A. Model Katmanı (`models/<feature>_model.dart`)
- `@immutable`, tüm alanlar `final`.
- `copyWith`, `fromJson`, `toJson` eksiksiz (kalıcılık için JSON zorunlu).
- Fiyat hesabı gibi saf iş kuralları modelde veya controller'da saf fonksiyon olarak yazılır (test edilebilir).

### B. Controller Katmanı (`controllers/<feature>_controller.dart`)
- İş mantığı, validasyon çağrısı, hesaplama ve `StorageService` çağrıları burada.
- Durumu `ValueNotifier<T>` ile açar; Flutter UI bağımlılığı yok (yalnızca `foundation.dart`).
- `dispose()` sunar (uygulama geneli controller'lar `main.dart` sahipliğinde dispose edilir).

### C. View Katmanı (`views/<feature>_view.dart`)
- Controller'ı alır/oluşturur ve dispose'u garanti eder.
- Hedef widget alanlarını `ValueListenableBuilder` ile sarar.
- 40 satırı aşan build parçalarını `widgets/` altına böler.
- Tüm metinler `context.tr('key')`, tüm renkler `Theme.of(context).colorScheme`/`AppColors`.

### D. Widget Katmanı (`widgets/*_widget.dart`, `*_painter.dart`)
- Mümkün olan her yerde `StatelessWidget` ve `const`.
- Painter'lar `shouldRepaint` içinde referans/değer karşılaştırması yapar.

---

## 3. Uygulama Geneli State (core/services)

| Controller | State | Kalıcı | Dinleyen |
|---|---|---|---|
| `SettingsController` | `ValueNotifier<ThemeMode>`, `ValueNotifier<Locale>` | Evet | `MaterialApp` (`ValueListenableBuilder`) |
| `AuthController` | `ValueNotifier<AuthState>` (`unauthenticated`, `authenticated`, `loading`, `failure`) | Evet (kullanıcı + oturum) | Kök yönlendirme (`main.dart`) |
| `ActiveRentalsController` | `ValueNotifier<List<ActiveRentalModel>>` | Evet | Aktif araçlar ekranı, harita (müsait araç filtresi) |

`main.dart` açılışta `await StorageService.init()` çağırır, controller'ları oluşturur ve `runApp`'e verir. Provider paketi yok; bağımlılıklar constructor ile aşağı geçer.

### Tema + Dil Örneği
```dart
ValueListenableBuilder<ThemeMode>(
  valueListenable: settings.themeMode,
  builder: (context, mode, _) => ValueListenableBuilder<Locale>(
    valueListenable: settings.locale,
    builder: (context, locale, _) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      locale: locale,
      home: const RootRouter(),
    ),
  ),
);
```

---

## 4. Kiralama Akışı State Modeli

```text
RentalMapController.selectedVehicle (ValueNotifier<VehicleModel?>)
        |  kullanıcı "Kirala" + plan seçer (dakikalık | paket)
        v
PaymentController.state (initial -> processing -> success | failure)   [test ödeme]
        | success
        v
ActiveRentalsController.start(vehicle, plan)  -> liste + persist
        |
        +-- extendTime(min) / addKm(km): extras kaydı eklenir, kalan hak artar
        +-- finish(): toplam = temel ücret + aşım + extras; kiralama kapanır
```

- Plan modeli: `RentalPlan { perMinute | package(id) }`.
- `ActiveRentalModel`: `id, vehicleId, plan, startedAt, includedMinutes, includedKm, usedKm, extras[], status`.
- Kalan süre `startedAt` ve `DateTime.now()` farkından hesaplanır; saniyelik güncelleme için tek bir `Ticker`/`Timer` tabanlı `ValueNotifier<DateTime> now` kullanılır (tüm sayfayı değil yalnızca sayaç widget'ını yeniler).
- Kullanılan km şimdilik simüle edilir (gerçek GPS yok).

---

## 5. Yaşam Döngüsü (Lifecycle) Standardı

```dart
class _ActiveRentalsViewState extends State<ActiveRentalsView> {
  late final ActiveRentalsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller; // veya yerel oluşturma
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ActiveRentalModel>>(
      valueListenable: _controller.rentals,
      builder: (context, rentals, _) => ActiveRentalList(rentals: rentals),
    );
  }
}
```

Yerelde oluşturulan controller view'da dispose edilir; dışarıdan verilen (uygulama geneli) controller view'da dispose EDİLMEZ.

---

## 6. Hata ve Yan Etki Yönetimi

- Asenkron işlemlerde durum: `initial`, `loading`, `success`, `failure`.
- Validasyon hataları alan bazlı `ValueNotifier<Map<String, String?>>` veya form state'inde tutulur; metinler çeviri anahtarı olarak taşınır, UI `context.tr` ile çözer.
- SnackBar/Dialog için callback veya ValueListenable dinleme kullanılır; UI'da karmaşık try-catch yazılmaz.
- `StorageService` bozuk JSON okursa varsayılan değere döner (veri kaybını önlemek için üzerine yazmadan önce log).
