# Tiknow – Sunum Rehberi ("Bu ekranın kodu nerede?")

Hoca arayüzde bir yeri gösterip "bunun kodu nerede?" derse bu dosyadan bak. Yollar `lib/` altındadır.

## 1. 30 Saniyelik Özet
- **Ne:** İstanbul haritasında araç seçip **dakikalık** veya **paket** (1 saat / 3 saat / tam gün) kiralama uygulaması.
- **Mimari:** Feature-first. Her modül `controllers/ models/ views/ widgets/` klasörlerine ayrılır.
- **State:** Sadece `ValueNotifier` + `ValueListenableBuilder`. Provider/Bloc/GetX yok, sayfa düzeyinde `setState` yok.
- **Harita:** Harici paket yok, `CustomPainter` ile çizildi.
- **Kalıcılık:** `shared_preferences`, yalnızca `StorageService` üzerinden.
- **Dil/Tema:** TR/EN, açık/koyu. Metinler `AppStrings`'te, renkler `AppColors`/`ColorScheme`'de.

## 2. Ekran → Kod Haritası

| Arayüzde gördüğün | Dosya | Not |
|---|---|---|
| Uygulamanın açılışı, oturum varsa harita yoksa kayıt | `main.dart` → `RootRouter` | `AuthState`'i dinler |
| Kayıt ekranı | `features/auth/views/register_view.dart` | Form + doğrulama |
| Giriş ekranı | `features/auth/views/login_view.dart` | |
| Şifre göster/gizle alanı | `features/auth/widgets/auth_text_field_widget.dart` | |
| Giriş/kayıt mantığı, hash | `features/auth/controllers/auth_controller.dart`, `core/utils/password_hasher.dart` | SHA-256 + salt |
| İstanbul haritası (deniz, yollar, yazılar) | `features/rental_map/widgets/istanbul_map_painter.dart` | `CustomPainter` |
| Harita koordinatları (kıyı, yollar, parklar) | `features/rental_map/models/istanbul_geo.dart` | Enlem/boylam → 0..1 |
| Kaydır/yakınlaştır, "konumuma git" butonu | `features/rental_map/widgets/rental_map_canvas_widget.dart` | `InteractiveViewer` |
| Turuncu araç simgeleri, mavi konum noktası | `features/rental_map/widgets/vehicle_marker_painter.dart` | Dokunma eşleştirme: `markerIndexAt` |
| Araçların listesi (12 araç) | `features/rental_map/models/vehicle_catalog.dart` | Fotoğraf URL'leri burada |
| Ana ekran, üst "Tiknow" çubuğu, ayarlar ikonu | `features/rental_map/views/rental_map_view.dart` | |
| Alt "Aktif Kiralamalar" butonu + rozet | `rental_map_view.dart` → `_ActiveRentalsButton` | |
| Araca dokununca açılan panel | `features/rental_map/widgets/vehicle_panel_widget.dart` | |
| Araç fotoğrafı (yükleniyor/hata) | `features/rental_map/widgets/vehicle_image_widget.dart` | `loadingBuilder`/`errorBuilder` |
| Vites / Yakıt / Fiyat satırları | `features/rental_map/widgets/vehicle_info_row_widget.dart` | |
| Dakikalık / 1 Saat / 3 Saat / Tam Gün kartları | `features/rental_map/widgets/package_selector_widget.dart` | |
| Paket tanımları ve aşım ücretleri | `features/rental_packages/models/rental_package_model.dart` | 150/380/900 TL |
| "10 dk yürüme" hesabı | `core/utils/distance_calculator.dart` | Haversine × 1,3 ÷ 80 |
| Seçili araç, seçili plan, müsait araçlar | `features/rental_map/controllers/rental_map_controller.dart` | Kiralanan araç haritadan düşer |
| Ödeme ekranı | `features/payment/views/payment_view.dart` | Test ödeme |
| Ödeme özeti | `features/payment/widgets/payment_summary_widget.dart` | |
| Kart formu (otomatik boşluk, AA/YY) | `features/payment/widgets/card_form_widget.dart` | |
| Ödeme durumu (işleniyor/başarılı/red) | `features/payment/controllers/payment_controller.dart` | `0000` ile biten kart reddedilir |
| Aktif kiralamalar ekranı | `features/active_rentals/views/active_rentals_view.dart` | Bitir onayı + döküm dialogu |
| Kiralama kartı, kalan süre sayacı | `features/active_rentals/widgets/active_rental_card_widget.dart` | |
| Süre / km ilerleme çubukları | `features/active_rentals/widgets/rental_usage_bar_painter.dart` | `CustomPainter` |
| "Süre uzat / Km ekle" alt sayfası | `features/active_rentals/widgets/extend_rental_sheet_widget.dart` | |
| Saniyelik sayaç, başlat/uzat/bitir | `features/active_rentals/controllers/active_rentals_controller.dart` | |
| **Fiyat hesabı (aşım, ekler, toplam)** | `features/active_rentals/models/active_rental_model.dart` | Saf fonksiyonlar, testli |
| Ayarlar ekranı | `features/settings/views/settings_view.dart` | |
| Tema seçici | `features/settings/widgets/theme_selector_widget.dart` | |
| Dil seçici | `features/settings/widgets/language_selector_widget.dart` | |
| Profil kartı | `features/settings/widgets/profile_header_widget.dart` | |
| E-posta / telefon / şifre değiştir | `features/settings/views/change_*_view.dart`, ortak iskelet `widgets/change_form_widget.dart` | Mantık: `profile_controller.dart` |
| Tüm metinler (TR/EN) | `core/constants/app_strings.dart` | `context.tr('anahtar')` |
| Renkler, harita paleti | `core/constants/app_colors.dart` | |
| Açık/koyu tema | `core/theme/app_theme.dart` | Material 3 |
| E-posta/telefon/şifre/kart doğrulama | `core/utils/validators.dart` | |
| "2,95 TL/dk" biçimi | `core/utils/money_formatter.dart` | |
| Veri kaydı (tema, dil, kullanıcı, kiralamalar) | `core/services/storage_service.dart` | Tek erişim noktası |
| Tema + dil durumu | `core/services/settings_controller.dart` | |
| Tek örnek controller'ların sahibi | `core/services/app_dependencies.dart` | `main.dart`'ta oluşur |

## 3. Veri Akışı (tahtada çizilecek tek şema)

```text
Kullanıcı dokunur → View → Controller metodu → ValueNotifier.value değişir
        → (StorageService'e kaydedilir) → ValueListenableBuilder sadece o widget'ı yeniler
```

**Kiralama akışı:** Haritada araç seç → `RentalMapController.select` → panel açılır → plan seç → "Kirala" →
`PaymentView` (başarılıysa `true` döner) → `ActiveRentalsController.start` → `ActiveRentalsView`.

## 4. Sık Sorulabilecek Sorular

**Harita nasıl çizildi, Google Maps mi?**
Hayır. `istanbul_geo.dart`'taki enlem/boylam noktaları 0..1'e çevrilir, `IstanbulMapPainter` poligon ve çizgi olarak çizer. Araçlar ayrı bir painter katmanıdır.

**Araca dokunduğumuzu nasıl anlıyor?**
`RentalMapCanvasWidget` içinde `GestureDetector.onTapUp`; dokunma noktası en yakın marker ile eşleştirilir (`VehicleMarkerPainter.markerIndexAt`, 24 dp yarıçap).

**Sayaç neden tüm sayfayı yenilemiyor?**
`ActiveRentalsController.now` tek bir `ValueNotifier<DateTime>`. Yalnızca onu dinleyen `ValueListenableBuilder` (kart içindeki `_UsageSection`) yeniden çizilir.

**Şifre nasıl saklanıyor?**
Düz metin değil. `PasswordHasher`: rastgele salt + SHA-256. Kullanıcı JSON'unda sadece hash ve salt var.

**Fiyat nasıl hesaplanıyor?**
`ActiveRentalModel.summaryAt(now)`:
- Dakikalık: `geçenDakika × dakikaFiyatı`.
- Paket: paket ücreti + aşım (`aşımDk × 2,90 + aşımKm × 2,90`) + eklenen süre/km ücretleri.
- Kullanılan km simüle: dakikada 0,5 km.

**Dil değişince nasıl anında değişiyor?**
`SettingsController.locale` bir `ValueNotifier`; `main.dart`'ta `MaterialApp` bunu `ValueListenableBuilder` ile dinler.