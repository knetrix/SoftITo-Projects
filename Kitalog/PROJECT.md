# Kitalog

Bu Döküman Kitalog Flutter Projesinde Geliştirme Yapacak Olan Ajan Yapay Zeka ve Yazılım Geliştiriciler için Bağlayıcı Bir Kılavuzdur. Projede Üretilen Her Kod Satırı Buradaki Kurallara (Özellikle 7-10. Bölümler) UYMAK ZORUNDADIR. Ajanın Yetenek Dosyaları: [.agents/skills/SKILL.md](.agents/skills/SKILL.md)

## 1. Proje Özeti

Kullanıcıların Sahip Oldukları Kitapları, Okuduklarını, Okuma Listelerini, Alıntılarını ve Kitap Değerlendirmelerini Kaydettiği Sanal Kütüphane.

## 2. Proje Amacı

Okuma Alışkanlığını Ölçmek, Ödünç Verilen Kitapları Takip Etmek ve Favori Alıntıları Kaybolmayacak Şekilde Arşivlemek.

## 3. Tahmini Ekran ve Sayfa Sayısı

4-5 Ekran (Kitaplığım Raf Görünümü, Yeni Kitap Ekle (ISBN/Arama), Okuma Durumu (Okunuyor/Bitti/Okunacak), Kitap Detay &amp; Alıntı Sayfası, Yıllık Okuma Hedefi Paneli).

## 4. Temel Özellikler

- Kitap Okuma İlerleme Yüzdesi ve Sayfa Sayacı, Alıntı ve Şahsi İnceleme, Not Bölümü, Yıllık Kitap Okuma Hedefi İlerleme Çubuğu, Türlere (Roman, Bilim, Tarih, vb.) Göre Renkli Etiketleme

## 5. Hedef Kitle

Genel Kullanıcılar, Öğrenciler veya İlgili Alan Profesyonelleri.

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler &amp; Kütüphaneler

- **Frontend:** Flutter (Stable, SDK ≥ 3.29) &amp; Dart (SDK ≥ 3.7, Null Safety)
  - Hedef Platformlar: Android ve iOS Öncelikli, Ardından Web ve Masaüstü
  - Tasarım Dili: Material 3, Varsayılan Koyu Tema ("Gece Kütüphanesi" Paleti: Mürekkep Siyahı &amp; Kehribar), Opsiyonel Aydınlık Tema ("Kağıt" Paleti)
  - State Yönetimi: Flutter Çekirdek API → `ValueNotifier` + `ValueListenableBuilder` (Harici State Paketi Yok)
  - Bağımlılık Paylaşımı: Çekirdek `InheritedWidget` Tabanlı `AppScope` (Provider/GetIt Yok)
  - Navigasyon: Çekirdek `Navigator` + İsimli Rotalar (`onGenerateRoute`)
- **Backend / Veri Depolama:** Gerçek Veritabanı Yok. Tüm Veriler Cihazda `shared_preferences` ile JSON Olarak Saklanır.
  - Depolama Erişimi Tek Bir Servisten Geçer: `core/storage/local_storage_service.dart`
  - İleride Gerçek Veritabanına (Örn: Firebase, SQLite) Geçişte Sadece Repository Katmanı Değişecek Şekilde Soyutlanır.
- **Ek Kütüphaneler / API'ler (Onaylı Liste):**


| Paket / API                                   | Amaç                                                                                                                        |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `shared_preferences`                          | Kullanıcı, Kitap, Alıntı, Not, Hedef ve Ayar Verilerinin Kalıcı Saklanması                                                  |
| `flutter_localizations` + `intl` (SDK)        | Türkçe/İngilizce Çoklu Dil (ARB + `gen-l10n`), Tarih Formatları                                                             |
| `image_picker`                                | Ayarlar'da Galeriden/Kameradan Profil Resmi Yükleme                                                                         |
| `http`                                        | Open Library API ile ISBN/Başlık Araması                                                                                    |
| `crypto`                                      | Şifrenin Düz Metin Yerine SHA-256 Hash Olarak Saklanması                                                                    |
| Open Library API                              | `https://openlibrary.org/search.json?q=` ve `https://openlibrary.org/isbn/<ISBN>.json` (Ücretsiz, API Anahtarı Gerektirmez) |
| Open Library Covers                           | `https://covers.openlibrary.org/b/isbn/<ISBN>-L.jpg` (Kitap Kapak Resimleri)                                                |
| `flutter_launcher_icons` (`dev_dependencies`) | Uygulama İkonunun Tüm Platformlar için Üretilmesi (Uygulamaya Dahil Olmaz, Sadece Geliştirme Aracı)                         |
| `flutter_native_splash` (`dev_dependencies`)  | İşletim Sisteminin Gösterdiği Yerel Açılış Ekranı (Flutter Motoru Yüklenirken Beyaz Ekran Yerine Logo)                      |


> Bu Listede Olmayan Her Paket için Kullanıcıdan ONAY Alınmalıdır.

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

```text
Uygulama Açılışı (Splash / Oturum Kontrolü)
 ├─ Oturum Yok ───────► Kayıt Ekranı ◄──► Giriş Ekranı
 │                           │ (Başarılı Kayıt / Giriş)
 └─ Oturum Var ───────────────┴──► Ana Kabuk (NavigationBar + Sağ Üst Ayarlar)
                                     ├─ Sekme 1: Kitaplığım (Raf Görünümü)
                                     │     ├─ FAB ► Yeni Kitap Ekle (ISBN / Arama / Manuel)
                                     │     └─ Kitaba Dokun ► Kitap Detay & Alıntı
                                     ├─ Sekme 2: Okuma Durumu (Okunuyor / Okunacak / Bitti)
                                     │     └─ Kitaba Dokun ► Kitap Detay & Alıntı
                                     ├─ Sekme 3: Yıllık Okuma Hedefi Paneli
                                     └─ Sağ Üst ⚙ ► Ayarlar (Profil, Tema, Dil, Hesap Bilgileri, Çıkış)
```



- [x] Sayfa 0 – Splash / Oturum Kontrolü: Yerel Açılış Ekranıyla (Bkz. 6.5) Aynı Zemin ve Logoyu Kullanır, Böylece Geçiş Kesintisiz Görünür. Kayıtlı Oturum Varsa Ana Kabuğa, Yoksa Kayıt Ekranına Yönlendirir. İlk Açılışta Örnek Kitap Verisini (Seed) Yükler.
- [x] Sayfa 1 – Kayıt &amp; Giriş: E-Posta, Telefon, Şifre (+ Şifre Tekrar) ile Kayıt; Mevcut Kullanıcı için E-Posta + Şifre ile Giriş (Bkz. 6.4).
- [x] Sayfa 2 – Kitaplığım (Raf Görünümü): Kitap Kapaklarının Raf/Grid Düzeninde Listelenmesi, Tür Etiketine ve Okuma Durumuna Göre Filtre, Başlık/Yazar Araması, Ödünç Verilen Kitaplarda Rozet.
- [x] Sayfa 3 – Yeni Kitap Ekle: ISBN ile Arama, Başlık/Yazar ile Arama (Open Library), Sonuç Bulunamazsa Manuel Form (Başlık, Yazar, Sayfa Sayısı, Tür, Kapak URL, Durum).
- [x] Sayfa 4 – Okuma Durumu: Okunuyor / Okunacak / Bitti Sekmeleri; Okunuyor Kartlarında İlerleme Yüzdesi ve Hızlı Sayfa Sayacı (+/-).
- [x] Sayfa 5 – Kitap Detay &amp; Alıntı: Kapak, Künye, Tür Etiketi, Sayfa Sayacı &amp; İlerleme Çubuğu, Durum Değiştirme, Puan (1-5) &amp; Şahsi İnceleme, Alıntılar (Sayfa No ile, Favori İşaretleme), Notlar, Ödünç Verme Bilgisi (Kime, Ne Zaman, İade Tarihi).
- [x] Sayfa 6 – Yıllık Okuma Hedefi Paneli: Yıllık Hedef Kitap Sayısı Belirleme, İlerleme Çubuğu (Biten / Hedef), Aylık Biten Kitap Dağılımı, Toplam Okunan Sayfa, Türlere Göre Dağılım.
- [x] Sayfa 7 – Ayarlar: Profil Resmi &amp; Kullanıcı Özeti, Tema, Dil, E-Posta / Telefon / Şifre Güncelleme, Çıkış Yap (Bkz. 6.4).

### 6.3. Veri Modeli ve Bileşen Tasarımı

Tüm Modeller `@immutable`, Tüm Alanlar `final`'dır ve `copyWith`, `fromJson`, `toJson` Metotlarını Eksiksiz İçerir. Birden Fazla Feature Tarafından Kullanılan Modeller `lib/core/models/` Altında Tutulur.

**Enum'lar**


| Enum            | Değerler                                                                                                                                                                                                                                                                                             |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadingStatus` | `toRead` (Okunacak), `reading` (Okunuyor), `finished` (Bitti)                                                                                                                                                                                                                                        |
| `BookGenre`     | `novel` (Roman), `science` (Bilim), `history` (Tarih), `philosophy` (Felsefe), `personalDevelopment` (Kişisel Gelişim), `sciFiFantasy` (Bilim Kurgu &amp; Fantastik), `biography` (Biyografi), `poetry` (Şiir), `children` (Çocuk), `other` (Diğer) – Her Türün Rengi `AppColors` İçinde Tanımlıdır. |
| `AvatarType`    | `none`, `preset` (Hazır Avatar), `custom` (Kullanıcının Yüklediği Resim)                                                                                                                                                                                                                             |


**Modeller**


| Model              | Alanlar                                                                                                                                                                                                | Not                                                                                                                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `UserModel`        | `id`, `email`, `phone`, `passwordHash`, `avatarType`, `avatarValue` (Hazır Avatar Anahtarı veya Dosya Yolu), `createdAt`                                                                               | Şifre Asla Düz Metin Saklanmaz.                                                                                                                                                            |
| `BookModel`        | `id`, `isbn?`, `title`, `authors` (`List<String>`), `coverUrl?`, `pageCount`, `currentPage`, `genre`, `status`, `rating?` (1-5), `review?`, `isOwned`, `loan?`, `startedAt?`, `finishedAt?`, `addedAt` | `progress` (= `currentPage / pageCount`, 0.0-1.0) Hesaplanan Getter'dır, Saklanmaz. `currentPage` 0 ile `pageCount` Arasında Sınırlanır; `pageCount`'a Ulaşınca Durum `finished` Önerilir. |
| `LoanModel`        | `borrowerName`, `lentAt`, `dueAt?`                                                                                                                                                                     | `BookModel.loan` Doluysa Kitap "Ödünçte" Sayılır.                                                                                                                                          |
| `QuoteModel`       | `id`, `bookId`, `text`, `page?`, `isFavorite`, `createdAt`                                                                                                                                             |                                                                                                                                                                                            |
| `NoteModel`        | `id`, `bookId`, `content`, `createdAt`, `updatedAt`                                                                                                                                                    |                                                                                                                                                                                            |
| `ReadingGoalModel` | `year`, `targetBookCount`                                                                                                                                                                              | Biten Kitap Sayısı `BookModel.finishedAt` Yılından Hesaplanır.                                                                                                                             |
| `AppSettingsModel` | `themeMode` (Varsayılan `dark`), `localeCode` (Varsayılan `tr`)                                                                                                                                        |                                                                                                                                                                                            |


**Depolama Anahtarları (`shared_preferences`)**


| Anahtar            | İçerik                          |
| ------------------ | ------------------------------- |
| `kitalog.user`     | `UserModel` JSON                |
| `kitalog.session`  | Oturum Açık mı (`bool`)         |
| `kitalog.books`    | `List<BookModel>` JSON          |
| `kitalog.quotes`   | `List<QuoteModel>` JSON         |
| `kitalog.notes`    | `List<NoteModel>` JSON          |
| `kitalog.goals`    | `List<ReadingGoalModel>` JSON   |
| `kitalog.settings` | `AppSettingsModel` JSON         |
| `kitalog.seeded`   | Örnek Veri Yüklendi mi (`bool`) |


**Katmanlı Veri Akışı**

```text
View / Widget ──(Aksiyon)──► Controller ──► Repository ──► LocalStorageService ──► SharedPreferences
      ▲                          │
      └──(ValueListenableBuilder)┴── ValueNotifier<State>
```

- `BookRepository`, `QuoteRepository`, `NoteRepository`, `GoalRepository`, `AuthRepository`, `SettingsRepository` → `lib/core/repositories/`
- Uygulama Geneli Paylaşılan Controller'lar (`AuthController`, `LibraryController`, `SettingsController`) `AppScope` Üzerinden Sağlanır; Ekrana Özel Controller'lar (Örn: `AddBookController`) View İçinde Oluşturulup `dispose` Edilir.

**Ortak Bileşenler (`lib/core/widgets/`)**

- `BookCoverImage` (Network Kapak + Yükleniyor/Hata Durumunda Tür Renginde Yer Tutucu)
- `GenreChip` (Türe Göre Renkli Etiket)
- `ReadingProgressBar` (Yüzde ve Sayfa Bilgisiyle İlerleme Çubuğu)
- `RatingStars` (1-5 Puan Gösterimi / Seçimi)
- `EmptyStateView` (Boş Liste Mesajı)

### 6.4 Yan Özellikler

- [] Uygulama Kayıt Ekranı ile Başlar. Kullanıcı Kayıt Olurken E-Posta, Telefon Numarası, Şifre İstenir. Bu Bilgilerin Validasyonu Sağlanmalıdır, Ayrıca Bilgilere Göre Uygun Format ve Klavye de Uygulanmalıdır. Kullanıcı Kayıt Olduktan Sonra Ana Sayfaya Yönlendirilir. Zaten Giriş Yapmış Kullanıcılar Ana Sayfaya Yönlendirilir.
- [] Sağ Üst: Ayarlar Simgesi
  - Profil Simgesi (Kayıt Olurken Seçmeyecek, Ayarlardan Hazır Resim veya Kendisi Yükleyebilecek. Profil Resmi Sonradan Değiştirilebilir), Kullanıcı Bilgilerinin Özeti.
  - Tema Seçimi: Karanlık (Varsayılan), Aydınlık).
  - Çoklu Dil Seçimi: Türkçe (Varsayılan) - İngilizce
  - E-Posta, Telefon, Şifre Güncellemesi (Güncelleme Yapılırken Kayıt Ekranında Olduğu Gibi Validasyon ve Formata Dikkat Edilmeli).

**Teknik Karşılıkları (Kayıt ve Ayarlar Ekranında AYNI Validator'lar Kullanılır → `lib/core/utils/validators.dart`)**


| Alan         | Klavye (`keyboardType`)         | Format / Kural                                                                                                                      |
| ------------ | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| E-Posta      | `TextInputType.emailAddress`    | Geçerli E-Posta Regex'i, Boşluk Kırpılır, Küçük Harfe Çevrilir. `autofillHints: [AutofillHints.email]`                              |
| Telefon      | `TextInputType.phone`           | Sadece Rakam (`FilteringTextInputFormatter.digitsOnly`) + Maske: `0 (5XX) XXX XX XX`; 0 ile Başlayan 11 Hane, İkinci Hane 5 Olmalı. |
| Şifre        | `TextInputType.visiblePassword` | `obscureText` + Göster/Gizle Butonu; En Az 8 Karakter, En Az 1 Büyük Harf, 1 Küçük Harf, 1 Rakam.                                   |
| Şifre Tekrar | `TextInputType.visiblePassword` | Şifre ile Eşleşmeli.                                                                                                                |


- Hata Mesajları Çoklu Dil Dosyalarından (ARB) Gelir; `AutovalidateMode.onUserInteraction` Kullanılır.
- Şifre Güncellemede Mevcut Şifre Doğrulanır. E-Posta Değişikliği Giriş Bilgisini de Günceller.
- Hazır Avatarlar `assets/avatars/` Altında Tutulur; Yüklenen Resim `image_picker` ile Seçilip Uygulama Dizinine Kopyalanır ve Yolu `UserModel.avatarValue`'ya Yazılır.
- Tema ve Dil Seçimi `SettingsController` Üzerinden Anında Uygulanır (`MaterialApp` `ValueListenableBuilder` ile Sarılır) ve Kalıcı Saklanır.
- Ayarlar Ekranında Ek Olarak "Çıkış Yap" Bulunur (Oturumu Kapatır, Veriler Silinmez, Giriş Ekranına Döner).

### 6.5 Ek Notlar

- Uygulamayı Test Etmek için / İlk Çalıştırırken Bol Sayıda Gerçek Kitap ve Kitaba Ait Resimler de Ekle.

**Teknik Karşılığı (Seed Data)**

- Örnek Veriler `lib/core/data/seed_data.dart` İçinde Tutulur ve `kitalog.seeded` Anahtarı `false` İken Sadece Bir Kez Yüklenir.
- En Az 30 Gerçek Kitap: Türk ve Dünya Edebiyatından Karışık (Örn: Sabahattin Ali, Orhan Pamuk, Yaşar Kemal, Dostoyevski, Orwell, Tolkien, Yuval Noah Harari, Carl Sagan vb.), Tüm Türlerden En Az 2 Kitap.
- Her Kitabın Gerçek ISBN'i ve Open Library Kapak URL'i Bulunur (`https://covers.openlibrary.org/b/isbn/<ISBN>-L.jpg`). ISBN'ler Kodlama Aşamasında Doğrulanmalıdır, Uydurma ISBN YASAKTIR.
- Kitaplar 3 Okuma Durumuna Dağıtılır; Okunanlara Puan &amp; İnceleme, Okunuyor Olanlara Farklı İlerleme Yüzdeleri, En Az 3 Kitaba Ödünç Bilgisi, Toplam En Az 15 Gerçek Alıntı (Sayfa No ile) ve Birkaç Not Eklenir.
- Bu Yılın Okuma Hedefi Örnek Olarak 24 Kitap Tanımlanır; Biten Kitapların `finishedAt` Tarihleri Yıl İçine Yayılır.
- Kapak Resmi Yüklenemezse (İnternet Yok / 404) `BookCoverImage` Tür Renginde Başlık Yazılı Yer Tutucu Gösterir.

**Uygulama İkonu ve Adı**

- **Konsept:** "Gece Kütüphanesi" Paletiyle Uyumlu; Koyu Mürekkep Zemin (`#14161B`) Üzerinde Kehribar (`#F2A93B`) Açık Kitap Silüeti, Ayraç veya "K" Harfi Detayı. Az Detaylı, 48px'te Bile Okunabilir, İçinde Yazı YOK.
- **Kaynak Dosya:** İkon SVG Olarak Tasarlanır (`assets/icon/app_icon.svg`) ve PNG'ye Dönüştürülür (`rsvg-convert` / ImageMagick vb.; Araç Yoksa Homebrew ile `librsvg` Kurulur).
- **Gerekli Dosyalar (`assets/icon/`):**


| Dosya                                 | Amaç                                                                               |
| ------------------------------------- | ---------------------------------------------------------------------------------- |
| `app_icon.png` (1024×1024)            | Ana İkon; iOS için Şeffaflık Yok, Zemin Dolu                                       |
| `app_icon_foreground.png` (1024×1024) | Android Adaptive İkon Ön Katmanı; Şeffaf Zemin, Logo Ortadaki \~%60 Güvenli Alanda |
| `app_icon_monochrome.png` (1024×1024) | Android 13+ Temalı (Tek Renk) İkon                                                 |


- **Uygulama:** `flutter_launcher_icons` ile Android (Adaptive + Monochrome, Arka Plan `#14161B`), iOS (`remove_alpha_ios: true`), Web (`background_color: #14161B`, `theme_color: #F2A93B`), Windows ve macOS İkonları Üretilir. Yapılandırma `pubspec.yaml` İçindeki `flutter_launcher_icons:` Bloğunda Tutulur.
- **Uygulama Adı:** Tüm Platformlarda Cihazda Görünen Ad "Kitalog" Olur (Android `android:label`, iOS `CFBundleDisplayName`, Web `manifest.json`, Masaüstü Pencere Başlığı).
- İkon ve Ad Değişikliği `flutter create` Sonrasında Uygulanır.

**Yerel Açılış Ekranı (Native Splash)**

- `flutter_native_splash` ile Üretilir; Yapılandırma `pubspec.yaml` İçindeki `flutter_native_splash:` Bloğunda Tutulur.
- Zemin Rengi `#14161B` (Koyu Tema ile Aynı), Ortada Uygulama Logosu (`assets/icon/splash_logo.png`, Şeffaf Zemin).
- Android 12+ için `android_12:` Bölümü Ayrıca Tanımlanır (Android 12+ Logoyu Daire İçinde Kırptığı için Logo Güvenli Alanda Olmalı).
- Android, iOS ve Web için Üretilir.

### 6.6. Proje Takvimi ve Teslim Aşamaları

- **Aşama 1 (Tasarım &amp; Wireframe):** Ekran Akışının ve Wireframe'lerin Çıkarılması, "Gece Kütüphanesi" (Koyu) ve "Kağıt" (Aydınlık) Renk Paletleri, Tür Renkleri, Tipografi, Uygulama İkonu Tasarımı (SVG → PNG); `flutter create`, Klasör İskeleti, `AppTheme`, `AppColors`, Çoklu Dil (ARB) Altyapısı, Veri Modelleri ve `LocalStorageService`.
- **Aşama 2 (Temel Fonksiyonlar &amp; Arayüz):** Kayıt/Giriş &amp; Oturum Yönlendirmesi → Kitaplığım Raf Görünümü + Seed Data → Kitap Detay (Sayfa Sayacı, İlerleme, Alıntı, Not, İnceleme, Ödünç) → Okuma Durumu Sekmeleri → Yeni Kitap Ekle (Open Library + Manuel) → Yıllık Hedef Paneli → Ayarlar (Profil, Tema, Dil, Hesap Güncelleme).
- **Aşama 3 (Test &amp; İyileştirme):** Validator, Model (`fromJson`/`toJson`) ve Controller Birim Testleri; Kayıt Formu ve Kitap Detay Widget Testleri; `flutter analyze` 0 Uyarı/0 Hata; Boş Durumlar, Hata Durumları (İnternet Yok, API Hatası), Erişilebilirlik ve Farklı Ekran Boyutları Kontrolü.
- **Aşama 4 (Final Teslim):** Android &amp; iOS Üzerinde Son Kontroller, Uygulama İkonunun `flutter_launcher_icons` ile Tüm Platformlara Uygulanması, Yerel Açılış Ekranının `flutter_native_splash` ile Oluşturulması ve Uygulama Adının "Kitalog" Olarak Ayarlanması, README &amp; Ekran Görüntüleri, Sunum.

### 6.7. Notlar &amp; Karşılaşılan Zorluklar

&lt;Geliştirme Esnasında Eklenen Notlar ve Çözüm Yolları&gt; &lt;Burayı Ben Dolduracağım, Elleme&gt;

---

## 7. Mimari Yapı: Özellik (Feature) Bazlı

- Kodlar Kesinlikle Tek Bir Yerde Toplanmayacaktır. Her Modül Kendi Feature Klasöründe Kodlanacaktır.
- Klasör İsimleri Çoğuldur ve Her Feature'da Aynıdır: `controllers/`, `models/`, `views/`, `widgets/`.
- Bir Feature Başka Bir Feature'ın `views/` veya `widgets/` Klasörünü Import Etmez; Ortak Olan Her Şey `core/` Altına Taşınır.

```text
lib/
    main.dart                       # Sadece Uygulama Başlatma (Storage init, AppScope, KitalogApp)
    app.dart                        # MaterialApp, Tema, Dil ve Rota Bağlantıları
    core/
        constants/
            app_colors.dart         # Tüm Renkler (Koyu & Aydınlık Palet + Tür Renkleri)
            app_sizes.dart          # Boşluk, Radius, İkon Boyutları
            storage_keys.dart       # shared_preferences Anahtarları
        theme/
            app_theme.dart          # ThemeData (Dark / Light), TextTheme
        extensions/
            context_extensions.dart # context.l10n, context.colors, context.textTheme
            genre_extensions.dart   # BookGenre → Renk / Etiket
        models/                     # Paylaşılan Modeller & Enum'lar (Bkz. 6.3)
        repositories/               # Book, Quote, Note, Goal, Auth, Settings Repository
        storage/
            local_storage_service.dart
        data/
            seed_data.dart
        di/
            app_scope.dart          # InheritedWidget: Paylaşılan Controller'lar
        routing/
            app_routes.dart         # Rota İsimleri ve onGenerateRoute
        utils/
            validators.dart
            phone_input_formatter.dart
        widgets/                    # Ortak Widget'lar (Bkz. 6.3)
    l10n/
        app_tr.arb                  # Şablon Dil (Varsayılan)
        app_en.arb
    features/
        splash/
        auth/                       # Kayıt & Giriş
        home_shell/                 # NavigationBar + Ayarlar Butonu
        library/                    # Kitaplığım Raf Görünümü
        add_book/                   # ISBN / Arama / Manuel Ekleme
        reading_status/             # Okunuyor / Okunacak / Bitti
        book_detail/                # Detay, Alıntı, Not, İnceleme, Ödünç
        reading_goal/               # Yıllık Okuma Hedefi Paneli
        settings/                   # Profil, Tema, Dil, Hesap
            controllers/
            models/
            views/
            widgets/
test/
    core/                           # Validator, Model, Repository Testleri
    features/<feature_name>/        # Controller & Widget Testleri
assets/
    avatars/                        # Hazır Profil Resimleri
    icon/                           # Uygulama İkonu (SVG Kaynak + PNG Çıktılar, Bkz. 6.5)
```

- `main.dart` Sadece Uygulama Başlatma ve Tema/Dil Bağlantısını İçerir; İş Mantığı Yazılmaz.
- Çoklu Dil için Proje Kökünde `l10n.yaml` Bulunur (`arb-dir: lib/l10n`, `template-arb-file: app_tr.arb`, `output-dir: lib/l10n/generated`, `output-localization-file: app_localizations.dart`) ve `pubspec.yaml`'da `flutter: generate: true` Açıktır.
- Yeni Feature İskeleti için: `bash .agents/skills/script/generate_feature.sh <feature_name>` (Proje Kökünden Çalıştırılır).

## 8. Kırmızı Çizgiler → Kod Kalite Standartları

1. **State Yönetim Standartları**
   - Sayfa Düzeyinde Ağır `setState` KULLANILMAYACAKTIR. State `ValueNotifier` + `ValueListenableBuilder` ile Yönetilir.
   - Sadece Yerel Arayüz Durumunu Yöneten (Örneğin Buton Animasyonları, Şifre Göster/Gizle, `TextEditingController` Sahipliği vb.) `StatefulWidget` Kabul Edilir.
   - Her Controller `dispose()` Metodu Sunar ve Sahibi Olan View Tarafından Çağrılır.
   - Ayrıntılar: [.agents/skills/references/state_flow.md](.agents/skills/references/state_flow.md)
2. **UI ve Performans Standartları**
   - Statik Tüm Widget'larda `const` Zorunludur.
   - Renk ve Metin Stilleri Kesinlikle Tema Dosyalarına (`app_colors.dart`, `app_theme.dart`) Yazılacaktır; Widget İçinde `Color(0x...)` veya `TextStyle(fontSize: ...)` YASAKTIR. `Theme.of(context)` / `context` Extension'ları Kullanılır.
   - Kullanıcıya Görünen Hiçbir Metin Koda Gömülmez (Hard-Coded); Tüm Metinler `app_tr.arb` ve `app_en.arb` Dosyalarında Tanımlanır ve `context.l10n` ile Okunur.
   - Büyük build Metotları Yasaktır, 40 Satırı Geçen build Metotları Özel Widget'lara (`widgets/`) Bölünecektir. Widget Döndüren `_buildXxx()` Yardımcı Metotları Yerine Ayrı Widget Sınıfları Tercih Edilir.
   - Listeler `ListView.builder` / `GridView.builder` ile Oluşturulur.
3. **Veri Standartları**
   - Modeller `@immutable`'dır; Güncellemeler `copyWith` ile Yeni Nesne Üretilerek Yapılır.
   - View ve Controller `SharedPreferences`'a Doğrudan Erişmez; Erişim Sadece Repository → `LocalStorageService` Üzerinden Olur.
   - Şifre Düz Metin Olarak Saklanmaz.
4. **Yasaklı Paketler**
   - Projeye Onay Almadan Harici Ağır State Paketleri (Bloc, Riverpod, Provider, GetX, MobX, Redux) ve DI/Router Paketleri (GetIt, go_router, auto_route) EKLENMEYECEKTİR.
   - 6.1'deki Onaylı Liste Dışında Paket Eklenmeden Önce Kullanıcıdan Onay Alınır.
   - Dart'ın ve Flutter'ın Yerel Çekirdek API'lerini Kullanmak Esastır.

## 9. Geliştirme Analiz ve Test Komutları

Ajan Yaptığı Herhangi Bir Kod Değişikliğinden Sonra Mutlaka Alttaki Komutların Çalıştığını Doğrulamalıdır.

- **Bağımlılıklar ve Dil Dosyaları**

```bash
flutter pub get
flutter gen-l10n
```

- **Statik Kod Analizi (0 Uyarı ve 0 Hata Şart)**

```bash
flutter analyze
```

- **Birim ve Widget Testleri**

```bash
flutter test
```

- **Uygulama İkonlarını Üretme (Sadece İkon Dosyaları Değiştiğinde)**

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

- **Projeyi Çalıştırma (iOS Simulator)**

```bash
flutter devices
flutter run -d E8204135-65EB-435D-812A-B84397808992 (flutter devices Çıktısına Göre Burası Değişebilir)
```

## 10. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe, Teknik Terimlerin Özünü Bozmadan Net ve Doğrudan Olacaktır.
- **Değişiklik Sunumları:** Örneğin 500 Satırlık Bir Dosyada 3 Satır Değiştiyse Tüm Dosyayı Baştan Sona Basma; Hedef Satırları ve Diff Yapısını Göster.
- **Dosya Yolları:** Bahsedilen ve Üretilen Her Dosya için Mutlaka Projeye Göre Tıklanabilir Link Ver.
- **Doğrulama:** Kod Yazdıktan Sonra Kullanıcıya "Şimdi flutter analyze ile Kontrol Edebilirsin" Şeklinde Doğrulama Yönergeleri Ver.
- **Kapsam:** Kullanıcının İstemediği Feature'ları veya Paketleri Kendiliğinden Ekleme; Belirsiz Bir Karar Varsa Sor.