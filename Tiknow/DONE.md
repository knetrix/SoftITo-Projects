# Tiknow – Yapılanlar (DONE.md)

Bu dosya, `PROJECT.md` ve `.agents/` klasörü analiz edilerek yapılan **her işlemin** adım adım kaydıdır.
Tarih: 2026-10-21 · Flutter 3.47.7 · Dart 3.13.5

---

## 0. Durum Özeti

| Kontrol | Sonuç |
|---|---|
| `flutter analyze` | **0 uyarı, 0 hata** |
| `flutter test` | **46 test geçti** (birim + widget) |
| Platformlar | Android, iOS, Web, macOS (Windows/Linux sonraya bırakıldı: PROJECT.md "Android/iOS öncelikli, ardından web ve masaüstü") |
| Paketler | `shared_preferences`, `crypto`, `flutter_launcher_icons` (dev) + SDK'nın `flutter_localizations` (bkz. Karar 1) |

---

## 1. Analiz Aşaması

### 1.1 `PROJECT.md` bulguları
- **Ürün:** İstanbul haritası üzerinden dakikalık veya paket bazlı araç kiralama (Material 3, açık/koyu tema, turuncu `#FF7A1A`, TR/EN, TL).
- **Mimari:** Feature-first (`auth`, `rental_map`, `rental_packages`, `payment`, `active_rentals`, `settings`) + `core/`.
- **State:** Yalnızca `ValueNotifier` + `ValueListenableBuilder`; sayfa düzeyinde `setState` yok; Provider/Bloc/Riverpod/GetX yok.
- **Harita:** Harici SDK yok; `CustomPainter` ile çizilen Google Maps görünümlü İstanbul haritası.
- **Kalıcılık:** `shared_preferences` yalnızca `StorageService` üzerinden.
- **Kimlik doğrulama:** Yerel, SHA-256 + salt ile hash, oturum bayrağı.
- **İş kuralları:** Dakikalık/paket/aşım/ek süre/ek km fiyatlandırması saf fonksiyon + birim testi; yürüme süresi = Haversine × 1,3 ÷ 80 m/dk (yukarı yuvarlama).
- **Kırmızı çizgiler:** `const`, tema renkleri (widget içinde `Colors.xxx` yok), 40 satırı geçen build yok, `Semantics` + 48 dp dokunma alanı, `shouldRepaint` doğru.
- **Doğrulama komutları:** `flutter analyze`, `flutter test`, `flutter run`; ikon: `dart run flutter_launcher_icons`.

### 1.2 `.agents/skills/` bulguları
| Dosya | Çıkarım |
|---|---|
| `SKILL.md` | Feature başına `controllers/ models/ views/ widgets/`; model `@immutable` + `copyWith/fromJson/toJson`; controller yalnızca `foundation.dart`; dışarıdan verilen controller view'da dispose edilmez. |
| `references/state_flow.md` | Tek yönlü veri akışı; `SettingsController` (tema+dil), `AuthController` (`AuthState`), `ActiveRentalsController`; `now` için tek `ValueNotifier<DateTime>` sayaç; asenkron durumlar `initial/loading/success/failure`; bozuk JSON → varsayılan. |
| `examples/sample_screen.dart` | `UsageBarPainter` örüntüsü (→ `RentalUsageBarPainter`), aşım + ek ücret hesabı (→ `ActiveRentalModel`). |
| `script/generate_feature.sh` | Klasör iskeleti üreticisi. Dosyaların elle yazılmasına karar verildi (bkz. Karar 3). |

---

## 2. Alınan Kararlar (gerekçeleriyle)

1. **`flutter_localizations` (SDK paketi) eklendi.** Harici l10n paketi YOK; ancak `Locale('tr')` ile Material bileşenleri (geri tuşu ipuçları, tarih/saat vb.) `MaterialLocalizations` olmadan hata verir. Bu paket Flutter SDK'nın parçasıdır (pub.dev bağımlılığı değil) ve "Flutter yerel çekirdek API'leri" ilkesiyle uyumludur. Tüm uygulama metinleri yine `AppStrings`'ten gelir. İstersen kaldırıp özel delegate yazılabilir.
2. **`AppDependencies` sınıfı eklendi** (`core/services/app_dependencies.dart`): `StorageService`, `SettingsController`, `AuthController`, `ActiveRentalsController` tek örnek olarak `main.dart`'ta oluşturulur, constructor ile aşağı verilir (Provider/InheritedWidget yok).
3. **Scaffold script'i çalıştırılmadı.** Script şablon dosyalar üretiyor (örnek model/view); PROJECT.md'deki hedef dosya ağacı daha ayrıntılı olduğundan dosyalar elle, hedef ağaca birebir yazıldı.
4. **Dakikalık planda süre/km ekleme yok.** Ek süre/km yalnızca paketlerde anlamlıdır (aşım fiyatları pakete bağlı).
5. **Dakikalıkta ödeme ekranında tutar 0,00 TL.** Ücret kiralama bitince `geçenDakika × dakikaFiyatı` olarak hesaplanır; ödeme ekranı kartı doğrular.
6. **Kullanılan km simüle edilir** (gerçek GPS yok): geçen dakika × 0,5 km/dk (≈30 km/sa). `ActiveRentalModel.simulatedKmPerMinute`.
7. **Test ödeme kuralı:** `0000` ile biten kart reddedilir (hata akışını denemek için).
8. **Tek yerel hesap:** Yeni kayıt, mevcut hesabın üzerine yazar. Oturum yoksa her zaman `RegisterView` açılır; hesap varsa "Giriş yap" bağlantısı görünür (PROJECT.md Bölüm 3).
9. **Araç görselleri** Wikimedia Commons `Special:FilePath` bağlantılarıdır (12 URL ayrıca `curl` ile 200/`image/jpeg` doğrulandı). Hatada araç ikonu gösterilir.
10. **Harita etkileşimi:** `InteractiveViewer` ile kaydır/yakınlaştır; simgeler `CustomPainter` ile çizilir ve yakınlaştırmada ekranda sabit boyutta kalır; dokunma eşleştirme yarıçapı 24 dp.

---

## 3. Yapılan İşlemler (kronolojik)

### Adım 1 – Proje iskeleti
- `flutter create --project-name tiknow --org com.softito --platforms android,ios,web,macos .`
- `flutter pub add shared_preferences crypto` · `flutter pub add --dev flutter_launcher_icons`
- `pubspec.yaml`: `flutter_localizations` (sdk) eklendi.

### Adım 2 – Çekirdek (`lib/core/`)
| Dosya | Görev |
|---|---|
| `constants/app_colors.dart` | `AppColors` (turuncu `#FF7A1A`, sabitler) ve `MapPalette` (açık/koyu harita renkleri). |
| `constants/app_strings.dart` | TR/EN `Map<String,String>`, `{yer_tutucu}` desteği, TR'ye geri düşüş. |
| `extensions/context_extension.dart` | `context.tr('key', args:)`, `context.colors`, `context.textStyles`. |
| `services/storage_service.dart` | `shared_preferences` tek erişim noktası: tema, dil, kullanıcı, oturum, aktif kiralamalar; bozuk JSON → varsayılan + log. |
| `services/settings_controller.dart` | `ValueNotifier<ThemeMode>` + `ValueNotifier<Locale>`; kalıcı. |
| `services/app_dependencies.dart` | Uygulama geneli controller'ların sahibi. |
| `theme/app_theme.dart` | Material 3 `light`/`dark`; `ColorScheme.fromSeed` + marka renkleri. |
| `utils/validators.dart` | E-posta, telefon (`5XXXXXXXXX`/`05XXXXXXXXX`, boşluk/parantez/tire temizleme), şifre (8+, büyük, küçük, rakam), tekrar, kart no (16 hane), SKT (AA/YY, geçmemiş), CVV. Hata **anahtarı** döner. |
| `utils/money_formatter.dart` | `2,95 TL`, `1.250,00 TL`, `2,95 TL/dk`. |
| `utils/distance_calculator.dart` | Haversine, `× 1,3 ÷ 80`, yukarı yuvarlama. |
| `utils/duration_formatter.dart` | `1 sa 30 dk`, sayaç `HH:MM:SS`. |
| `utils/password_hasher.dart` | SHA-256 + rastgele salt (`crypto`). |

### Adım 3 – Modeller (hepsi `@immutable`, `copyWith/fromJson/toJson`)
- `auth/models/user_model.dart`
- `rental_map/models/vehicle_model.dart` (+ `FuelType`), `vehicle_catalog.dart` (**12 araç**, İstanbul'un farklı semtlerinde: Cihangir, Beşiktaş, Şişli, Mecidiyeköy, Sultanahmet, Kadıköy, Üsküdar, Acıbadem, Bebek, Aksaray, Göztepe, Galata), `istanbul_geo.dart` (kara/kıyı poligonları, parklar, yollar, enlem-boylam → 0..1 dönüşümü).
- `rental_packages/models/rental_package_model.dart`: 1 Saat/30 km/150 TL, 3 Saat/80 km/380 TL, Tam Gün/250 km/900 TL; aşım 2,90 TL/km ve 2,90 TL/dk (Tam Gün 2,60); `RentalPlan` (dakikalık | paket).
- `active_rentals/models/active_rental_model.dart`: **saf fiyat fonksiyonları** (`elapsedMinutes`, `usedKm`, `remainingSeconds`, `overMinutes`, `overKm`, `overageFee`, `extrasFee`, `summaryAt`), `RentalExtraModel`, `RentalSummary`.
- `payment/models/payment_model.dart`, `settings/models/profile_model.dart`.

### Adım 4 – Controller'lar (yalnızca `foundation`, `ValueNotifier`)
- `AuthController`: `AuthState {unauthenticated, authenticated, loading, failure}`, `register/login/logout/updateUser`.
- `ProfileController`: e-posta, telefon, şifre değişikliği (eski şifre doğrulaması şart).
- `RentalMapController`: müsait araçlar (kiralanan araç haritadan düşer), seçili araç, seçili plan, yürüme süresi.
- `PaymentController`: `initial → processing → success | failure`.
- `ActiveRentalsController`: `start/extendTime/addKm/finish`, saniyelik `now` sayacı (yalnızca aktif kiralama varken Timer çalışır), kalıcılık.

### Adım 5 – Görünümler ve widget'lar
- **auth:** `register_view`, `login_view`, `auth_text_field_widget` (göster/gizle), `auth_header_widget`.
- **rental_map:** `rental_map_view`, `rental_map_canvas_widget` (kaydır/yakınlaştır, konuma dön), `istanbul_map_painter` (deniz/Boğaz/Haliç/Marmara, kara, parklar, ara/ana yollar, semt ve su etiketleri; açık/koyu palet), `vehicle_marker_painter` (simgeler + kullanıcı konumu + `semanticsBuilder`), `vehicle_panel_widget`, `vehicle_info_row_widget`, `package_selector_widget`, `vehicle_image_widget` (`Image.network` + `loadingBuilder`/`errorBuilder`).
- **payment:** `payment_view`, `payment_summary_widget`, `card_form_widget` (otomatik biçimlendirme: `1234 5678 …`, `AA/YY`).
- **active_rentals:** `active_rentals_view`, `active_rental_card_widget`, `extend_rental_sheet_widget`, `rental_usage_bar_painter` (süre ve km çubukları).
- **settings:** `settings_view`, `change_email_view`, `change_phone_view`, `change_password_view`, `change_form_widget` (ortak iskelet), `theme_selector_widget`, `language_selector_widget`, `profile_header_widget`.
- `main.dart`: `StorageService.init()` → `AppDependencies` → `ValueListenableBuilder` (tema + dil) → `RootRouter` (oturum varsa harita, yoksa kayıt).

### Adım 6 – Testler (`test/`)
| Dosya | Kapsam |
|---|---|
| `validators_test.dart` | E-posta, telefon, şifre, kart, SKT, CVV |
| `utils_test.dart` | TL biçimi, Haversine/yürüme süresi, süre biçimi, parola hash |
| `pricing_test.dart` | Dakikalık, paket, süre/km aşımı, ekler, JSON gidiş-dönüş |
| `controllers_test.dart` | Ayarlar kalıcılığı, kayıt/giriş/çıkış, profil, ödeme, kiralama akışı, bozuk JSON |
| `app_strings_test.dart` | TR/EN anahtar eşitliği, yer tutucu uyumu, kodda kullanılan her anahtarın tanımlı olması |
| `widget_test.dart` | Kayıt akışı, dil anında değişir, oturum kalıcılığı, ayarlar + çıkış, ödeme akışı |

**Testlerin yakaladığı gerçek hatalar (düzeltildi):**
- Harita simgelerinin `SemanticsProperties`'inde `textDirection` eksikti (erişilebilirlik ağacında assertion).
- Dar ekranda ödeme/aktif kiralama satırlarında etiket + değer taşması → etiketler `Expanded` yapıldı.
- Test beklentisi (Taksim–Cihangir yürüme süresi) elle tahmin edilmişti; hesaplanan 10 dk ile düzeltildi (kod doğruydu).

### Adım 7 – Uygulama ikonu ve platform ayarları
- `tool/make_icon_test.dart` ile (PIL yok → Flutter `Canvas`) `assets/icon/app_icon.png` (1024×1024, turuncu zemin + beyaz konum iğnesi içinde beyaz araç) ve `app_icon_foreground.png` (adaptive, şeffaf) üretildi.
- `pubspec.yaml` → `flutter_launcher_icons` yapılandırıldı; `dart run flutter_launcher_icons` çalıştırıldı (Android, iOS, Web, macOS).
- Android: `INTERNET` izni (görseller için), uygulama adı **Tiknow**.
- macOS: `com.apple.security.network.client` yetkisi (Release); iOS `CFBundleDisplayName`; web başlık/manifest.

### Adım 8 – Görsel doğrulama
- Geçici bir önizleme giriş noktası (sonra silindi; analyzer uyarısı veriyordu) ile iOS simülatöründe ekranlar açılıp ekran görüntüsü alındı (sonuçlar Bölüm 4'te).

---

## 4. Görsel Doğrulama Notları

iOS simülatöründe (iPhone 18 Pro) `SCREEN=panel` ile doğrulandı:
- Harita (kara/deniz/yollar/etiketler), turuncu araç simgeleri, kullanıcı konumu noktası doğru çiziliyor.
- Cihangir'deki araca dokununca alt panel açılıyor: **10 dk yürüme**, gerçek Renault Clio fotoğrafı (Wikimedia'dan yüklendi), model-plaka, vites, yakıt, fiyat, Dakikalık/1 Saat/3 Saat/Tam Gün seçici ve "Dakikalık kirala" butonu.
- Gözlem (kabul edildi): seçili simge panelin hemen üstünde kalıyor; harita ilk açılışta kullanıcı konumuna yakınlaşık başlıyor.
- Diğer ekranlar (`active`, `settings`, `payment`, `register`) widget testleriyle doğrulandı; simülatörde yalnızca harita+panel gözle incelendi.

---

## 5. Doğrulama Komutları

```bash
flutter analyze            # 0 uyarı, 0 hata
flutter test               # 46 test
flutter run                # uygulamayı çalıştır
dart run flutter_launcher_icons
```

## 6. Bilinen Sınırlar / Sonraki Adımlar
- Gerçek GPS, gerçek ödeme ve backend yok (PROJECT.md gereği).
- Windows/Linux platformları eklenmedi.
- Android/iOS gerçek cihaz testi yapılmadı; iOS simülatöründe çalıştırıldı.
