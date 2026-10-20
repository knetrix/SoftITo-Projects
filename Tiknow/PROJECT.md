# Tiknow (Dakika ve Paket Bazlı Akıllı Araç Kiralama Uygulaması)

Bu Döküman Flutter Projesinde Geliştirme Yapacak Olan Ajan Yapay Zeka ve Yazılım Geliştiriciler için Bağlayıcı Bir Kılavuzdur. Projede Üretilen Her Kod Satırı Buradaki Kurallara UYMAK ZORUNDADIR.

## 1. Proje Özeti ve Teknolojiler

- **Uygulama Adı:** Tiknow (İstanbul Haritası Üzerinden Dakika veya Paket Bazlı Araç Kiralama Uygulaması)
- **Hedef Platformlar:** Android ve iOS Öncelikli, Ardından Web ve Masaüstü Platformları
- **Flutter SDK**: 3.47.7
- **Dart SDK**: 3.13.5
- **Tasarım Dili:** Material 3, Çift Tema (Açık ve Koyu), Turuncumsu Ana Renk (Örn: `#FF7A1A`)
- **Harita Motoru:** Özel Yerel Çözüm. Gerçek harita SDK'sı kullanılmaz; Google Maps görünümlü İstanbul haritası `CustomPainter` ile çizilir (karalar, deniz/Boğaz, ana yollar, etiketler). Harita statik varlık (asset) görseli üzerine `CustomPainter` marker katmanı şeklinde de kurulabilir.
- **Kalıcılık:** `shared_preferences` (Tema, dil, kullanıcı hesabı, oturum, aktif kiralamalar)
- **Çoklu Dil:** Türkçe (varsayılan) ve İngilizce
- **Para Birimi:** TL (Biçim: `2,95 TL/dk`)
- **Uygulama İkonu:** Turuncu zemin üzerine beyaz araç + konum iğnesi sembolü. `flutter_launcher_icons` ile Android/iOS'a uygulanır (bkz. Bölüm 7).

## 2. Mimari Yapı: Özellik Bazlı (Feature-First)

- Kodlar Kesinlikle Tek Bir Yerde Toplanmayacaktır. Her Modül Kendi Feature Klasöründe Kodlanacaktır.

```text
lib/
    core/
        constants/
            app_colors.dart
            app_strings.dart          # TR/EN çeviri haritaları ve anahtarlar
        extensions/
            context_extension.dart    # context.tr('key'), context.colors vb.
        services/
            storage_service.dart      # shared_preferences sarmalayıcı (tek erişim noktası)
            settings_controller.dart  # Tema + Dil ValueNotifier'ları (uygulama geneli)
        theme/
            app_theme.dart            # lightTheme / darkTheme
        utils/
            validators.dart           # E-posta, telefon, şifre validasyonları
            money_formatter.dart      # TL biçimlendirme
            distance_calculator.dart  # Yürüme süresi hesabı

    features/
        auth/
            controllers/
                auth_controller.dart
            models/
                user_model.dart
            views/
                login_view.dart
                register_view.dart
            widgets/
                auth_text_field_widget.dart
                auth_header_widget.dart
        rental_map/
            controllers/
                rental_map_controller.dart
            models/
                vehicle_model.dart
            views/
                rental_map_view.dart
            widgets/
                istanbul_map_painter.dart
                vehicle_marker_painter.dart
                vehicle_panel_widget.dart
                vehicle_info_row_widget.dart
                package_selector_widget.dart
        rental_packages/
            models/
                rental_package_model.dart
        payment/
            controllers/
                payment_controller.dart
            models/
                payment_model.dart
            views/
                payment_view.dart
            widgets/
                payment_summary_widget.dart
                card_form_widget.dart
        active_rentals/
            controllers/
                active_rentals_controller.dart
            models/
                active_rental_model.dart
            views/
                active_rentals_view.dart
            widgets/
                active_rental_card_widget.dart
                extend_rental_sheet_widget.dart
                rental_usage_bar_painter.dart
        settings/
            controllers/
                profile_controller.dart
            models/
                profile_model.dart
            views/
                settings_view.dart
                change_email_view.dart
                change_phone_view.dart
                change_password_view.dart
            widgets/
                theme_selector_widget.dart
                language_selector_widget.dart
                profile_header_widget.dart
    main.dart
```

## 3. Akış (Navigasyon)

1. Açılış: `StorageService` ve `SettingsController` yüklenir (tema + dil).
2. Kayıtlı oturum yoksa → `RegisterView` (kayıtlı hesap varsa `LoginView` bağlantısı). Oturum varsa → `RentalMapView`.
3. `RentalMapView`: İstanbul haritası, turuncu araç simgeleri. Sağ üstte ayarlar simgesi → `SettingsView`. Alt gezinme veya buton ile `ActiveRentalsView`.
4. Araç simgesine tıkla → `VehiclePanelWidget` (bottom sheet): yürüme dakikası, fotoğraf, model-plaka, vites, yakıt, fiyat, paketler. Kullanıcı "Dakikalık" veya bir paketi seçip kiralamayı onaylar.
5. → `PaymentView` (test ödeme, gerçek ödeme YOK). Başarılı ödeme → aktif kiralama oluşturulur → `ActiveRentalsView`.
6. `ActiveRentalsView`: kalan süre/km, süre uzat, km ekle, kiralamayı bitir. Eklemeler kaydedilir; bitişte ekstra ücret toplam ücrete eklenir.

## 4. İş Kuralları

### Fiyatlandırma
- **Dakikalık:** `araç.dakikaFiyati` (Örn: 2,95 TL/dk). Bitişte `geçenDakika × dakikaFiyati`.
- **Paket:** Örn. `1 saat / 30 km / 150 TL`, `3 saat / 80 km / 380 TL`, `Tam Gün / 250 km / 900 TL`. Her paket için aşım ücretleri ayrı tutulur: `aşımKmFiyatı` (Örn: 2,90 TL/km) ve `aşımDakikaFiyatı` (Örn: 2,90 TL/dk).
- **Uzatma / Ek Km:** Aktif ekranda eklenen süre veya km, `extras` listesine yazılır ve bitişte ekstra ücret olarak toplama eklenir. Eklenen süre/km kalan hakka da eklenir.
- Aşım: Süre veya km hakkı bittiyse her ek dakika/km için aşım ücreti işler.
- Tüm fiyat hesapları saf (UI'sız) fonksiyonlarla controller/model katmanında yapılır, birim testi zorunludur.

### Yürüme Mesafesi
- Kullanıcı konumu şimdilik sabit (örn. Taksim) ya da simüle. Gerçek GPS bu aşamada YOK.
- Hesap: Haversine mesafe × 1,3 (sokak sapma katsayısı) ÷ 80 m/dk, yukarı yuvarlanır.

### Validasyonlar (`validators.dart`)
- **E-posta:** Standart regex, boş olamaz.
- **Cep Telefonu:** Türkiye biçimi, `5XXXXXXXXX` (10 hane) veya `05XXXXXXXXX`; boşluk/parantez temizlenir.
- **Şifre:** En az 8 karakter, en az 1 büyük harf, 1 küçük harf, 1 rakam.
- **Şifre tekrarı** eşleşmeli. Kart (test): 16 hane, Luhn kontrolü gerekmez; SKT ve CVV biçim kontrolü.
- Hata metinleri `AppStrings` üzerinden çok dilli.

### Kimlik Doğrulama (yerel)
- Backend yok; hesap `shared_preferences`'ta saklanır. Şifre düz metin saklanmaz; `crypto` paketi ile SHA-256 + salt hash'lenir.
- Giriş: e-posta + şifre. Oturum bayrağı saklanır; çıkışta temizlenir.
- Profil: e-posta, telefon, şifre değişikliği (eski şifre doğrulaması şart).

### Kalıcılık
- Saklananlar: tema modu (`system/light/dark`), dil (`tr/en`), kullanıcı, oturum, aktif kiralamalar (JSON).
- `shared_preferences` erişimi yalnızca `StorageService` üzerinden yapılır; view/controller doğrudan çağırmaz.

### Çoklu Dil
- Harici l10n paketi yok. `AppStrings` içinde `tr` ve `en` `Map<String, String>`; `context.tr('anahtar')` eklentisi.
- Dil değişimi `SettingsController.locale` `ValueNotifier` ile anında yansır, `MaterialApp` `ValueListenableBuilder` ile sarılır.
- Ekranda sabit metin YASAK; tüm metinler `AppStrings` anahtarından gelir.

### Görseller
- Araç fotoğrafları gerçek araç görselleridir (ör. Wikimedia Commons / lisansa uygun kaynaklar), `Image.network` + `loadingBuilder`/`errorBuilder` ile gösterilir. Placeholder/ikon yedeği yalnızca hata durumunda.
- Araç verisi şimdilik yerel sabit listedir (min. 8 araç, İstanbul'un farklı semtlerinde, farklı model/vites/yakıt).

## 5. Kırmızı Çizgiler -> Kod Kalite Standartları

1. **State Yönetim Standartları**
   - Sayfa Düzeyinde Ağır `setState` KULLANILMAYACAKTIR.
   - Sadece Yerel Arayüz Durumunu Yöneten (Örn: Buton mikro animasyonları, yerel form alanları, `TextEditingController`) StatefulWidget Kabul Edilir.
   - Tüm iş akışı ve modül durumu Flutter yerel `ValueNotifier` ve `ValueListenableBuilder` ile yürütülür.
   - Uygulama geneli durum (tema, dil, oturum) tek bir `SettingsController`/`AuthController` örneğiyle `main.dart`'ta oluşturulur ve constructor ile aşağı verilir (InheritedWidget/Provider paketi yok).

2. **UI, Grafik ve Performans Standartları**
   - Statik Tüm Widget'larda `const` Zorunludur.
   - Renk ve Metin Stilleri Kesinlikle Tema ve Sabit Dosyalarına Yazılacaktır (`AppColors`, `AppTheme`). Açık ve koyu tema için renkler `ColorScheme` üzerinden alınır; widget içinde `Colors.xxx` sabit renk yasaktır.
   - Büyük build Metotları Yasaktır; 40 Satırı Geçen build Metotları Özel Widget'lara Bölünecektir.
   - Harita ve grafikler `CustomPainter` ile çizilir, `shouldRepaint` doğru uygulanır, 60/120 fps hedeflenir.
   - Erişilebilirlik: Marker ve butonlara `Semantics` etiketi, yeterli dokunma alanı (min 48 dp).

3. **Yasaklı / İzinli Paketler**
   - Projeye Onay Almadan Harici Ağır State Paketleri (Bloc, Riverpod, MobX, Redux, GetX, Provider) EKLENMEYECEKTİR.
   - Harici ağır chart/grafik/harita paketleri (fl_chart, google_maps_flutter, flutter_map vb.) eklenmeyecektir.
   - **İzinli (onaylı):** `shared_preferences`, `crypto`, `flutter_launcher_icons` (dev). Başka paket için önce onay istenir.
   - Dart'ın ve Flutter'ın Yerel Çekirdek API'lerini Kullanmak Esastır.

## 6. Geliştirme Analiz ve Test Komutları

Ajan Yaptığı Herhangi Bir Kod Değişikliğinden Sonra Mutlaka Alttaki Komutların Çalıştığını Doğrulamalıdır:

- **Statik Kod Analizi (0 Uyarı ve 0 Hata Şart)**
```bash
flutter analyze
```

- **Birim ve Widget Testleri** (fiyat hesabı, validasyonlar, yürüme süresi için zorunlu)
```bash
flutter test
```

- **Projeyi Çalıştırma**
```bash
flutter run
```

## 7. Uygulama İkonu

- Kaynak: `assets/icon/app_icon.png` (1024×1024, turuncu zemin, beyaz araç + iğne) ve `assets/icon/app_icon_foreground.png` (adaptive icon).
- `pubspec.yaml` içinde `flutter_launcher_icons` yapılandırılır; uygulama komutu:
```bash
dart run flutter_launcher_icons
```

## 8. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe Teknik Terimlerin Özünü Bozmadan Net ve Doğrudan Olacaktır.
- **Değişiklik Sunumları:** Örnek 500 Satırlık Bir Dosyada 3 Satır Değiştiyse Tüm Dosyayı Baştan Sona Basma; Hedef Satırları ve Diff Yapısını Göster.
- **Dosya Yolları:** Bahsedilen ve Üretilen Her Dosya için Mutlaka Projeye Göre Tıklanabilir Link Ver.
- **Doğrulama:** Kod Yazdıktan Sonra Kullanıcıya "Şimdi flutter analyze ile Kontrol Edebilirsin" Şeklinde Doğrulama Yönergeleri Ver.
