# Money Habit Tracker

Bu Döküman Flutter Projesinde Geliştirme Yapacak Olan Ajan Yapay Zeka ve Yazılım Geliştiriciler için Bağlayıcı Bir Kılavuzdur. Projede Üretilen Her Kod Satırı Buradaki Kurallara UYMAK ZORUNDADIR. Bu Kılavuzla Çelişen Bir Skill veya Örnek Kod Görülürse Geçerli Olan Bu Dosyadır.

## 1\. Proje Özeti

Kullanıcıların Para Yönetimini Alışkanlığa Dönüştürmesini Amaçlayan; 10 Günlük Finansal Görevlerden Oluşan Challenge'ları, Kişisel Finansal Hedefleri ve Günlük Harcama Takibini (Expense Tracker) Tek Bir Uygulamada Birleştiren Finansal Alışkanlık Takip Uygulaması.

- **Uygulama Adı:** Money Habit Tracker
- **Cihazda Görünen Ad (Tüm Platformlar):** Money Habit (Bkz. 12.1)
- **Paket Adı (pubspec `name`):** `money_habit_tracker`
- **Hedef Platformlar:** Android ve iOS Öncelikli, Ardından Web ve Masaüstü Platformları
- **Flutter SDK:** 3.47.7 (Stable)
- **Dart SDK:** `^3.13.5` (Flutter 3.47.7 ile Gelen Sürüm)
- **Tasarım Dili:** Material 3, Koyu Tema Varsayılan (Gece Finans Paleti: Deep Navy & Emerald / Gold), Aydınlık Tema Seçilebilir

## 2\. Proje Amacı

Tasarruf ve Harcama Bilincini Küçük, Günlük Görevlerle Adım Adım Geliştirmek; Kötü Alışkanlıklardan (Örn: Sigara) Vazgeçilerek Biriken Parayı Somut Bir Finansal Hedefe Dönüştürmek ve Günlük Harcamaları Kaydederek Bütçeyi Kontrol Altında Tutmak.

## 3\. Tahmini Ekran ve Sayfa Sayısı

5 Ana Ekran + 3 Yardımcı Ekran:

- **Ana Ekranlar (Alt Navigasyon / `NavigationBar`):** Ana Panel (Genel Özet), 10 Günlük Challenge Ekranı (Günlük Finansal Görevler), Finansal Hedeflerim (Hedef Ekle & İlerleme Adımları), Harcama Kaydı (Harcama Ekle & Harcama Listesi), Bütçe & İstatistik Paneli.
- **Yardımcı Ekranlar:** Kayıt Ekranı, Giriş Ekranı, Ayarlar Ekranı.

## 4\. Temel Özellikler

- 10 Günlük Finansal Görev Challenge'ı ve Günlük Görev Tamamlama (Gün Sayacı ve Seri / Streak Takibi)
- Kişisel Finansal Hedef Oluşturma (Hedef Adı ve Hedef Tutar; Örn: Sigarayı Bırak – Hedef 5000 TL) ve Hedefe İlerleme Adımları (Para Ekleme) ile Takip
- Hedef İlerleme Yüzdesi ve İlerleme Çubuğu
- Günlük Harcama Kaydı (Tutar, Kategori, Tarih, Not)
- Aylık Bütçe Limiti ve Kalan Bütçe Göstergesi
- Harcamaların Kategorilere (Market, Ulaşım, Fatura, Eğlence, vb.) Göre Renkli Etiketlenmesi ve Grafiksel Dağılımı

## 5\. Hedef Kitle

Genel Kullanıcılar, Öğrenciler, Yeni Çalışma Hayatına Başlayan Gençler ve Harcamalarını Kontrol Altına Alıp Tasarruf Alışkanlığı Kazanmak İsteyen Herkes.

---

## 6\. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler & Kütüphaneler

- **Frontend:** Flutter (Material 3) + Dart
- **State Yönetimi:** Flutter Çekirdek API'leri: `ValueNotifier` + `ValueListenableBuilder` (Harici State Paketi YOK)
- **Navigasyon:** Flutter Çekirdek `Navigator` + İsimli Rotalar (`onGenerateRoute`, `core/router/app_router.dart`)
- **Backend / Veri Depolama:** Gerçek Veritabanı Yok. Yerel Kalıcı Depolama: `shared_preferences` (Model'ler `toJson` → `jsonEncode` ile String Olarak Saklanır). Tüm Erişim Tek Bir `LocalStorageService` Üzerinden Yapılır; İleride Gerçek Veritabanına Geçişte Sadece Bu Servis Değişir.
- **Çoklu Dil:** `flutter_localizations` (SDK) + `intl` + `flutter gen-l10n` (ARB Dosyaları: `app_tr.arb`, `app_en.arb`)
- **Grafikler:** Flutter Çekirdek `CustomPainter` ile Pasta / Halka (Donut) ve Çubuk Grafik
- **Ek Kütüphaneler / API'ler (Onaylı Beyaz Liste):**

| Paket | Amaç | Not |
|---|---|---|
| `shared_preferences` | Kullanıcı, Ayarlar, Challenge, Hedef, Harcama ve Bütçe Verilerinin Kalıcı Saklanması | Zorunlu |
| `flutter_localizations` (sdk) | TR / EN Dil Desteği | Zorunlu |
| `intl` | Para Birimi (`₺`) ve Tarih Formatlama | Zorunlu |
| `image_picker` | Profil Resmini Galeriden / Kameradan Yükleme | Zorunlu |
| `path_provider` | Seçilen Profil Resmini Uygulama Dizinine Kopyalama | Zorunlu (Web Hariç) |
| `crypto` | Şifreyi SHA-256 Hash Olarak Saklama (Düz Metin Şifre YASAK) | Zorunlu |
| `flutter_launcher_icons` (dev) | Uygulama İkonunun Tüm Platformlara Uygulanması | Bkz. 12 |
| `flutter_native_splash` (dev) | Yerel Açılış Ekranı (Android 12+ Dahil) | Bkz. 12 |

> Bu Listede Olmayan Her Paket (Örn: `provider`, `bloc`, `riverpod`, `get`, `go_router`, `fl_chart`, `hive`) için Önce Kullanıcıdan Onay Alınacaktır.

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

```text
Uygulama Açılışı (main.dart → LocalStorageService.init())
   ├── Oturum Yok  → Kayıt Ekranı (/register) ⇄ Giriş Ekranı (/login)
   └── Oturum Var  → Ana Kabuk (/home, NavigationBar)
                         ├── Sekme 1: Ana Panel
                         ├── Sekme 2: Challenge
                         ├── Sekme 3: Hedeflerim
                         ├── Sekme 4: Harcamalar
                         └── Sekme 5: Bütçe & İstatistik
                     AppBar Sağ Üst ⚙️ → Ayarlar (/settings)
```

- \[ \] **Sayfa 0 – Kayıt / Giriş (`auth`):** E-Posta, Telefon, Şifre (+ Şifre Tekrar) ile Kayıt. Başarılı Kayıt → Oturum Açılır → `/home` (Geri Tuşu ile Kayıt Ekranına Dönülemez: `pushNamedAndRemoveUntil`). Kayıtlı Kullanıcı Uygulamayı Açınca Direkt `/home`'a Gider. Çıkış Yapmış Kullanıcı için Giriş Ekranı (E-Posta + Şifre).
- \[ \] **Sayfa 1 – Ana Panel (`dashboard`):** Karşılama Başlığı, Bu Ayki Kalan Bütçe Kartı, Aktif Challenge'ın Bugünkü Görevi ve Streak Sayısı, En Yakın Hedefin İlerleme Çubuğu, Son 3-5 Harcama. Kartlara Dokununca İlgili Sekmeye Geçilir.
- \[ \] **Sayfa 2 – 10 Günlük Challenge (`challenge`):** Hazır Challenge Şablonundan Başlatma, 10 Günlük Görev Listesi (Gün 1…10), Sadece Bugünün Görevi Tamamlanabilir (Gelecek Günler Kilitli), Gün Sayacı (Örn: 4/10), Güncel ve En İyi Streak, Challenge Bitince Tebrik Ekranı / Dialog ve Yeniden Başlatma.
- \[ \] **Sayfa 3 – Finansal Hedeflerim (`goals`):** Hedef Listesi (Kart: Ad, Biriken / Hedef Tutar, Yüzde, İlerleme Çubuğu), Hedef Ekleme (BottomSheet / Form: Ad + Hedef Tutar), Hedef Detayı: İlerleme Adımları Listesi ve "Para Ekle" (Tutar + Opsiyonel Not), Hedefe Ulaşınca "Tamamlandı" Rozeti, Hedef Silme.
- \[ \] **Sayfa 4 – Harcama Kaydı (`expenses`):** Harcama Ekleme Formu (Tutar, Kategori Seçimi, Tarih Seçici, Not), Tarihe Göre Gruplanmış Harcama Listesi, Kategori Renkli Etiketleri (Chip), Kaydırarak Silme (`Dismissible`) ve Geri Al (SnackBar), Ay Filtresi.
- \[ \] **Sayfa 5 – Bütçe & İstatistik (`budget`):** Aylık Bütçe Limiti Belirleme / Güncelleme, Harcanan / Kalan Bütçe Göstergesi (Limit Aşılırsa Uyarı Rengi), Kategori Dağılımı Halka Grafiği + Lejant, Son 7 Gün Harcama Çubuk Grafiği.
- \[ \] **Sayfa 6 – Ayarlar (`settings`):** Bkz. 6.4.

### 6.3. Veri Modeli ve Bileşen Tasarımı

**Genel Kurallar:**

- Tüm Modeller `@immutable`, Tüm Alanlar `final`; `copyWith`, `fromJson`, `toJson` Zorunlu.
- **Para Tutarları `int` Kuruş Olarak Saklanır** (Örn: 125,50 TL → `12550`). `double` ile Para Hesabı YASAK. Ekranda Gösterim `intl` `NumberFormat.currency` ile Yapılır.
- Tarihler `toIso8601String()` ile Saklanır. Ay Anahtarı Formatı: `yyyy-MM` (Örn: `2026-10`).
- `id` Alanları `DateTime.now().microsecondsSinceEpoch.toString()` ile Üretilir (Harici `uuid` Paketi Gerekmez).

| Model | Alanlar | Açıklama |
|---|---|---|
| `UserModel` | `id`, `email`, `phone`, `passwordHash`, `avatar` (`AvatarModel?`), `createdAt` | Kayıtlı Kullanıcı. Şifre Asla Düz Metin Tutulmaz. |
| `AvatarModel` | `type` (`AvatarType.preset` / `AvatarType.file`), `value` (Hazır Avatar Asset Yolu veya Dosya Yolu) | Profil Resmi. Kayıtta `null`, Ayarlardan Atanır. |
| `AppSettingsModel` | `themeMode` (`ThemeMode.dark` Varsayılan), `localeCode` (`'tr'` Varsayılan) | Tema ve Dil Tercihleri |
| `ChallengeModel` | `id`, `title`, `tasks` (`List<ChallengeTaskModel>`, 10 Adet), `startDate`, `currentStreak`, `bestStreak`, `isCompleted` | Aktif Challenge |
| `ChallengeTaskModel` | `dayNumber` (1-10), `title`, `description`, `completedAt` (`DateTime?`) | `isCompleted` → `completedAt != null` Getter'ı |
| `GoalModel` | `id`, `title`, `targetAmount` (Kuruş), `steps` (`List<GoalStepModel>`), `createdAt` | `savedAmount` ve `progress` (0.0-1.0) Getter Olarak Hesaplanır, Saklanmaz |
| `GoalStepModel` | `id`, `amount` (Kuruş), `date`, `note` (`String?`) | Hedefe Para Ekleme Adımı |
| `ExpenseModel` | `id`, `amount` (Kuruş), `category` (`ExpenseCategory`), `date`, `note` (`String?`) | Tek Bir Harcama Kaydı |
| `ExpenseCategory` (enum) | `market`, `transport`, `bills`, `entertainment`, `health`, `education`, `other` | Renkler `AppColors.category*`, İkonlar `ExpenseCategory` Extension'ında, İsimler l10n'dan |
| `BudgetModel` | `monthKey` (`yyyy-MM`), `limitAmount` (Kuruş) | Aylık Bütçe Limiti. `spent` / `remaining` Controller'da Hesaplanır |

**Challenge & Streak Kuralları:**

- Her Takvim Gününde Yalnızca O Günün Görevi Tamamlanabilir (`dayNumber = bugün - startDate + 1`).
- Görev Tamamlanınca: Bir Önceki Gün de Tamamlanmışsa `currentStreak + 1`, Değilse `currentStreak = 1`; `bestStreak = max(bestStreak, currentStreak)`.
- Bir Gün Kaçırılırsa Görev "Kaçırıldı" Olarak Görünür, Challenge Devam Eder Fakat Streak Sıfırlanır.
- 10. Gün Bitince `isCompleted = true`; Kullanıcı Yeni Challenge Başlatabilir.

**SharedPreferences Anahtarları (`core/constants/storage_keys.dart`):**

| Anahtar | Tip | İçerik |
|---|---|---|
| `user` | String (JSON) | `UserModel` |
| `is_logged_in` | bool | Oturum Durumu |
| `app_settings` | String (JSON) | `AppSettingsModel` |
| `active_challenge` | String (JSON) | `ChallengeModel` |
| `goals` | String (JSON List) | `List<GoalModel>` |
| `expenses` | String (JSON List) | `List<ExpenseModel>` |
| `budgets` | String (JSON List) | `List<BudgetModel>` |

**Ortak Bileşenler (`core/widgets/`):** `AppPrimaryButton`, `AppTextField` (Validasyon + Klavye Tipi Parametreli), `AmountText` (Kuruş → `₺` Formatı), `ProgressBarCard`, `EmptyStateWidget`, `SectionHeader`.

### 6.4 Yan Özellikler

- \[ \] **Kayıt Ekranı:** Uygulama Kayıt Ekranı ile Başlar. Kullanıcı Kayıt Olurken E-Posta, Telefon Numarası, Şifre İstenir. Kullanıcı Kayıt Olduktan Sonra Ana Sayfaya Yönlendirilir. Zaten Giriş Yapmış Kullanıcılar Ana Sayfaya Yönlendirilir.
  - **Validasyon (`core/utils/validators.dart`, Kayıt ve Ayarlarda ORTAK Kullanılır):**
    - E-Posta: Boş Olamaz, Regex ile Geçerli Format (`ornek@alan.com`).
    - Telefon: TR Formatı, `5` ile Başlayan 10 Hane (Önünde `0` / `+90` Kabul Edilip Normalize Edilir). Ekranda `5XX XXX XX XX` Maskesi.
    - Şifre: En Az 8 Karakter, En Az 1 Büyük Harf, 1 Küçük Harf, 1 Rakam. Şifre Tekrar Alanı Eşleşmeli.
  - **Klavye ve Format:** E-Posta → `TextInputType.emailAddress` + `autocorrect: false`; Telefon → `TextInputType.phone` + `FilteringTextInputFormatter.digitsOnly` + `LengthLimitingTextInputFormatter`; Şifre → `obscureText: true` + Göster / Gizle İkonu; `textInputAction` ile Alanlar Arası `next` / `done` Geçişi; Uygun `autofillHints`.
- \[ \] **Sağ Üst: Ayarlar Simgesi** (Tüm Ana Sekmelerin AppBar'ında)
  - **Profil:** Profil Simgesi (Kayıt Olurken Seçilmez; Ayarlardan Hazır Resim (`assets/avatars/`) veya Kendisi Galeriden / Kameradan Yükleyebilir. Profil Resmi Sonradan Değiştirilebilir). Avatar Yoksa E-Posta Baş Harfi Gösterilir. Kullanıcı Bilgilerinin Özeti (E-Posta, Maskelenmiş Telefon, Kayıt Tarihi).
  - **Tema Seçimi:** Karanlık (Varsayılan), Aydınlık. Seçim Anında Uygulanır ve Kalıcı Saklanır.
  - **Çoklu Dil Seçimi:** Türkçe (Varsayılan) - İngilizce. Seçim Anında Uygulanır ve Kalıcı Saklanır.
  - **Hesap Güncelleme:** E-Posta, Telefon, Şifre Güncellemesi (Kayıt Ekranındaki Aynı Validator'lar ve Klavye / Format Kuralları Kullanılır; Şifre Değişiminde Mevcut Şifre Doğrulanır).
  - **Çıkış Yap:** Oturum Kapatılır (`is_logged_in = false`), Kullanıcı Giriş Ekranına Yönlendirilir. Veriler Silinmez.

### 6.5. Proje Takvimi ve Teslim Aşamaları

- **Aşama 1 (Tasarım & Wireframe):** Ekran Wireframe'leri, Renk Paleti (`AppColors`) ve Tema (`AppTheme` Dark / Light), Klasör Yapısının Kurulması, `pubspec.yaml` Paketleri, `LocalStorageService`, `AppRouter`, l10n Altyapısı (TR / EN ARB).
- **Aşama 2 (Temel Fonksiyonlar & Arayüz):** Sırasıyla `auth` (Kayıt / Giriş / Oturum) → `expenses` → `budget` → `goals` → `challenge` → `dashboard` → `settings` Feature'larının Model + Controller + View + Widget Katmanlarıyla Kodlanması.
- **Aşama 3 (Test & İyileştirme):** Validator ve Controller Birim Testleri (Streak, Bütçe, Hedef Yüzdesi Hesapları), Kritik Ekranlar için Widget Testleri, `flutter analyze` 0 Uyarı / 0 Hata, Farklı Ekran Boyutları ve Her İki Tema / Dil Kontrolü.
- **Aşama 4 (Final Teslim):** Android ve iOS'ta Uçtan Uca Test, Uygulama İkonu & Splash, README ve Ekran Görüntüleri, Ardından Web / Masaüstü Uyumluluğu.

---

## 7\. Mimari Yapı: Özellik Bazlı (Feature-First)

- Kodlar Kesinlikle Tek Bir Yerde Toplanmayacaktır. Her Modül Kendi Feature Klasöründe Kodlanacaktır.
- Klasör İsimleri Çoğuldur ve Tüm Feature'larda Aynıdır: `controllers/`, `models/`, `views/`, `widgets/`.
- Feature'lar Birbirinin `views/` veya `widgets/` Klasörünü Import Etmez; Ortak İhtiyaçlar `core/` Altına Taşınır. (İstisna: `dashboard` ve `home` Diğer Feature'ların Controller / Model'lerini Okuyabilir.)

```text
lib/
    core/
        constants/
            app_colors.dart          # Tüm Renkler (Tema + Kategori Renkleri)
            app_sizes.dart           # Padding, Radius, Spacing Sabitleri
            storage_keys.dart        # SharedPreferences Anahtarları
        extensions/
            context_extensions.dart  # context.l10n, context.theme, context.colors
            money_extensions.dart    # int (Kuruş) → '₺1.250,50'
            date_extensions.dart     # monthKey, isSameDay, vb.
        l10n/
            app_tr.arb
            app_en.arb
        router/
            app_router.dart          # İsimli Rotalar + onGenerateRoute
        services/
            local_storage_service.dart
        theme/
            app_theme.dart           # AppTheme.dark / AppTheme.light
            app_text_styles.dart
        utils/
            validators.dart          # E-Posta, Telefon, Şifre (Kayıt + Ayarlar Ortak)
            password_hasher.dart
        widgets/                     # Feature'lar Arası Ortak Widget'lar
    features/
        auth/                        # Kayıt, Giriş, Oturum
        home/                        # NavigationBar Kabuğu (Sekme Yönetimi)
        dashboard/                   # Ana Panel
        challenge/                   # 10 Günlük Challenge + Streak
        goals/                       # Finansal Hedefler + İlerleme Adımları
        expenses/                    # Harcama Kaydı
        budget/                      # Bütçe & İstatistik + Grafikler
        settings/                    # Profil, Tema, Dil, Hesap Güncelleme
            controllers/
            models/
            views/
            widgets/
    app.dart                         # MaterialApp (Tema, Locale, Router Bağlantısı)
    main.dart                        # Sadece Başlatma: WidgetsFlutterBinding, Storage init, runApp
test/
    core/utils/validators_test.dart
    features/<feature_name>/<feature_name>_controller_test.dart
assets/
    avatars/                         # Hazır Profil Resimleri
l10n.yaml
```

#### `main.dart` Sadece Uygulama Başlatma, `app.dart` Sadece Tema / Dil / Rota Bağlantısı İçerir. İş Mantığı Yazılmaz.

## 8\. Kırmızı Çizgiler -> Kod Kalite Standartları

1. **State Yönetim Standartları**

- Sayfa Düzeyinde Ağır `setState` KULLANILMAYACAKTIR. Durum, Controller İçindeki `ValueNotifier` ile Yönetilir ve `ValueListenableBuilder` ile Dinlenir.
- Sadece Yerel Arayüz Durumunu Yöneten (Örneğin Buton Animasyonları, Şifre Göster / Gizle, Seçili Sekme İndeksi vb.) StatefulWidget Kabul Edilir.
- Controller'lar `dispose()` Metodu Sunar; View `State.dispose()` İçinde Bunu Çağırmak Zorundadır.
- Global Durumlar (Tema, Dil, Oturum) Tek Bir Yerde (`settings` / `auth` Controller'ları) Tutulur ve `app.dart` Üzerinden Dinlenir.

2. **UI ve Performans Standartları**

- Statik Tüm Widget'larda `const` Zorunludur.
- Renk ve Metin Stilleri Kesinlikle Tema Dosyalarına Yazılacaktır (`AppColors`, `AppTheme`, `Theme.of(context)`). Widget İçinde `Color(0x...)` veya `Colors.xxx` YASAK.
- Büyük `build` Metotları Yasaktır, 40 Satırı Geçen `build` Metotları Özel Widget'lara Yazılacaktır.
- Kullanıcıya Görünen Hiçbir Metin Kod İçine Sabit Yazılmaz (Hardcoded String YASAK); Tüm Metinler `app_tr.arb` / `app_en.arb` Dosyalarından `context.l10n` ile Alınır.
- Listeler `ListView.builder` / `SliverList` ile Oluşturulur.

3. **Veri ve Güvenlik Standartları**

- Para Tutarları `int` Kuruş; `double` ile Para Hesabı YASAK.
- Şifre Düz Metin Saklanmaz; `crypto` ile SHA-256 Hash Olarak Saklanır.
- `SharedPreferences`'a View veya Widget'tan Doğrudan Erişim YASAK; Sadece Controller → `LocalStorageService` Üzerinden.
- Formlar `Form` + `GlobalKey<FormState>` + `TextFormField.validator` ile Doğrulanır.

4. **Yasaklı Paketler**

- Projeye Onay Almadan Harici Ağır State Paketleri (`provider`, `bloc`, `riverpod`, `get`, `mobx`, `redux`) EKLENMEYECEKTİR.
- 6.1'deki Beyaz Listede Olmayan Her Paket için Önce Onay Alınacaktır.
- Dart'ın ve Flutter'ın Yerel Çekirdek API'lerini Kullanmak Esastır.

## 9\. Geliştirme Analiz ve Test Komutları

Ajan Yaptığı Herhangi Bir Kod Değişikliğinden Sonra Mutlaka Alttaki Komutların Çalıştığını Doğrulamalıdır.

- **Bağımlılıklar ve Dil Dosyaları (pubspec veya ARB Değiştiyse)**

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

- **Projeyi Çalıştırma**

Flutter Projesi Aşağıdaki Komut ile Çalıştırılabilir (iOS Simulator). Emulator Hali Hazırda Açık.

```bash
flutter run -d E8204135-65EB-435D-812A-B84397808992
```

Başka Bir Cihaz Gerekirse:

```bash
flutter emulators && flutter devices
flutter run -d ... (Flutter Devices Komut Çıktısına Göre Üç Nokta Değişecek)
```

- **Yeni Feature İskeleti Oluşturma (Proje Kök Dizininde)**

```bash
bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh <feature_name>
```

## 10\. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe, Teknik Terimlerin Özünü Bozmadan Net ve Doğrudan Olacaktır.

- **Değişiklik Sunumları:** Örneğin 500 Satırlık Bir Dosyada 3 Satır Değiştiyse Tüm Dosyayı Baştan Sona Basma; Hedef Satırları ve Diff Yapısını Göster.

- **Dosya Yolları:** Bahsedilen ve Üretilen Her Dosya için Mutlaka Projeye Göre Tıklanabilir Link Ver.

- **Doğrulama:** Kod Yazdıktan Sonra Kullanıcıya "Şimdi `flutter analyze` ile Kontrol Edebilirsin" Şeklinde Doğrulama Yönergeleri Ver.

- **Paket Ekleme:** Beyaz Liste Dışında Bir Paket Gerekiyorsa Kodlamadan Önce Gerekçesiyle Birlikte Kullanıcıya Sor.

## 11\. İlerleme Takibi: DONE.md

Yapılan Her İşlem, Takip Edilebilmesi için `DONE.md` Dosyasına Aşağıdaki Formata Uyularak Yazılır.

- Yapılan Her Değişiklikten Sonra, Küçük Düzeltmeler Dahil, `DONE.md` Güncellenir.
- Format Şöyle:
  - En Üstte `| Aşama | Durum |` Tablosu Bulunur.
  - Her Adımın Başlığı `## [YYYY-MM-DD] Aşama X – Başlık` Şeklindedir.
  - Her Adımda Sırasıyla Şunlar Yer Alır: **Yapılanlar**, **Dosyalar**, **Doğrulama** (`flutter analyze` ve `flutter test` Sonuçları), **Alınan Kararlar**, **Açık Konular**.
  - **Dosyalar** Bölümü Oluşturulan / Güncellenen / Silinen Diye Gruplanır ve Her Dosya Tek Cümleyle Açıklanır.
- Sondaki **Final Özet** de Güncel Tutulur.
- **Neden:** Proje `DONE.md` Üzerinden Takip Edilecektir.

## 12\. Ek Notlar

### 12.1. İkon ve Açılış Ekranı

- Uygulama İkonu SVG Olarak Tasarlanır; Bu SVG'den PNG Dosyaları Üretilir (Ana İkon, Android Ön Katman, Tek Renkli İkon, Açılış Ekranı Logosu) ve `flutter_launcher_icons` ile Tüm Platformlara Uygulanır.
- Yerel Açılış Ekranı `flutter_native_splash` ile Oluşturulur (Android 12+ Dahil).
- Uygulama Adı Tüm Platformlarda `"Money Habit"` Olarak Ayarlanır.

### 12.2. Geliştirme Kolaylıkları

Uygulamayı Geliştirirken Kolaylık Olması Açısından:

- Projeye Uygun Mock Data Eklenir.
- Giriş Sayfasında Hızlı Giriş için Test Kullanıcısı Oluşturulur.
