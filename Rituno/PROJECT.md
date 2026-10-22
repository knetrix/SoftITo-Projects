# Rutino - Alışkanlık, Seri ve Topluluk Takip Uygulaması

> **Önemli Kılavuz Bildirimi:**  
> Bu döküman Flutter projesinde geliştirme yapacak olan yapay zeka ajanları ve yazılım geliştiriciler için **bağlayıcı bir kılavuzdur**. Projede üretilen her kod satırı buradaki kurallara ve mimariye **UYMAK ZORUNDADIR**.

---

## 1. Proje Özeti ve Vizyon
Kullanıcıların günlük rutinlerini ve alışkanlıklarını organize ettiği; kesintisiz seri (streak), puanlama ve otomatik turnuvalarla motive olduğu; yapay zeka destekli analizler ve topluluk etkileşimi içeren modern bir alışkanlık takibi uygulamasıdır.

- **Uygulama Adı:** Rutino
- **Hedef Platformlar:** Android ve iOS (Öncelikli), ardından Web ve Masaüstü (macOS, Windows, Linux)
- **Tasarım Dili:** Material 3, Koyu Tema (Varsayılan: Gece Odak Modu / Dark Obsidian & Canlı Vurgular) ve Aydınlık Tema (Çift Tema Desteği)

---

## 2. Proje Amacı
Kullanıcıların motivasyonunu sürekli yüksek tutarak kalıcı pozitif alışkanlıklar edinmelerini sağlamak; oyunlaştırma (seri/puan/turnuva), yapay zeka özetleri ve topluluk desteği ile erteleme alışkanlığını kıran sürdürülebilir bir kişisel gelişim deneyimi sunmaktır.

---

## 3. Tahmini Ekran ve Sayfa Sayısı
Uygulama 5 ana ekran / sekmeden oluşur:
1. **Kimlik Doğrulama Ekranları:** Giriş Yap & Kayıt Ol (Validasyonlar ve yönlendirmeler).
2. **Alışkanlıklar (Ana Sayfa Sekmesi):** Günlük alışkanlık listesi, tamamlama aksiyonları, filtreleme ve yeni alışkanlık ekleme/düzenleme.
3. **İstatistikler & Yapay Zeka (2. Sekme):** Başarı grafikleri, seri (streak) takvimi, kazanılan puanlar ve Yapay Zeka özet/tavsiye kartı.
4. **Topluluk & Turnuvalar (3. Sekme):** Ortak alışkanlık havuzu, topluluk paylaşımları ve sistemin otomatik oluşturduğu turnuvaların liderlik tablosu.
5. **Profil & Ayarlar:** Kullanıcı profil özeti, avatar seçimi, çift tema seçimi, çoklu dil (TR/EN) ve hesap bilgileri güncelleme.

---

## 4. Temel Özellikler
- **Alışkanlık Yönetimi:** Alışkanlık ekleme, düzenleme, arşivleme, silme ve kişiselleştirilebilir bildirim/hatırlatıcı ayarları.
- **İstatistik & Oyunlaştırma:** Alışkanlıkların detaylı istatistik takibi, kesintisiz devam serisi (streak) sayacı, seviye ve puan sistemi.
- **Yapay Zeka Analizi:** Kullanıcı verilerini inceleyerek durum özeti çıkaran, motivasyon sağlayan ve kişiye özel gelişim tavsiyeleri veren yapay zeka motoru.
- **Topluluk & Otomatik Turnuvalar:** Kullanıcıların kendi alışkanlıklarını paylaşabilmesi, ortak alışkanlıklara katılabilmesi ve sistemin otomatik oluşturduğu haftalık/aylık turnuvalarda rekabet edebilmesi.
- **Çoklu Dil & Tema:** Türkçe (varsayılan) ve İngilizce dil desteği, Material 3 Koyu (varsayılan) ve Açık tema uyumu.

---

## 5. Hedef Kitle
Yeni rutinler kazanmak isteyenler, erteleme alışkanlığını kırmayı hedefleyenler, hedeflerine ulaşırken oyunlaştırma ve topluluk rekabetinden motive olan bireyler ve öğrenciler.

---

## 6. Mimari Yapı ve Teknik Kurallar

### 6.1. Kullanılacak Teknolojiler & Standartlar
- **Flutter SDK:** 3.29.0
- **Dart SDK:** 3.0.0+
- **Arayüz:** Material 3 Tasarım Sistemi (Dark Theme Varsayılan)
- **Durum Yönetimi (State Management):** Harici ağır paketler (Bloc, Riverpod vb.) kesinlikle kullanılmayacaktır. Dart ve Flutter'ın yerel çekirdek API'si olan **`ValueNotifier`** ve **`ValueListenableBuilder`** esastır.
- **Veri Depolama (Kalıcılık):** Yerel depolama önceliklidir (SharedPreferences / Hive / SQLite). Modeller JSON serileştirme (`fromJson`/`toJson`) destekleyecektir.
- **Harici Entegrasyonlar:**
  - Yapay Zeka Entegrasyonu (Gemini / OpenAI REST API entegrasyonu)
  - Bildirim Servisi (Yerel anlık bildirimler)
  - Varlık Yönetimi (`flutter_launcher_icons`, `flutter_native_splash`)

---

### 6.2. Mimari Yapı: Özellik Bazlı (Feature-First Architecture)

Kodlar kesinlikle tek bir yerde toplanmayacaktır. Her modül kendi feature klasöründe bağımsız olarak kodlanacaktır:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   └── ai_service.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│   ├── habits/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│   ├── statistics/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│   ├── community/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│   └── profile/
│       ├── controllers/
│       ├── models/
│       ├── views/
│       └── widgets/
└── main.dart
```

> **Not:** `main.dart` yalnızca uygulama başlatma, servis ön-yüklemeleri ve ana tema/yönlendirme yapılandırmasını içerir.

---

### 6.3. Sayfa Hiyerarşisi ve Akış Planı

- [ ] **Sayfa 1 (Kimlik Doğrulama):**
  - Giriş Yap & Kayıt Ol ekranları.
  - E-posta, telefon ve şifre validasyonları, uygun klavye türleri (emailAddress, phone, textPassword).
  - Kayıt veya giriş sonrası doğrudan Ana Sayfaya (Alışkanlıklar sekmesi) yönlendirme.
  - Oturumu açık olan kullanıcılar açılışta doğrudan ana ekrana geçer.

- [ ] **Sayfa 2 (1. Sekme - Alışkanlıklar / Ana Sayfa):**
  - Günlük alışkanlık listesi, filtreler (Bugün, Tümü, Tamamlananlar).
  - Tek dokunuşla tamamlama / geri alma aksiyonu.
  - Yeni alışkanlık ekleme/düzenleme dialogu/sayfası (Başlık, açıklama, sıklık, hatırlatma saati).

- [ ] **Sayfa 3 (2. Sekme - İstatistikler & Analiz):**
  - Haftalık/Aylık başarı grafikleri ve devam serisi (streak) takvimi.
  - Kazanılan toplam puan ve mevcut seviye rozetleri.
  - Yapay Zeka özet ve motivasyon/tavsiye kartı ("Analiz Et" aksiyonu ile tetiklenebilir).

- [ ] **Sayfa 4 (3. Sekme - Topluluk & Turnuva):**
  - Ortak alışkanlık keşif havuzu ve "Katıl" aksiyonu.
  - Topluluk üyelerinin başarı paylaşımları.
  - Sistemin haftalık/aylık otomatik oluşturduğu turnuva sıralama (leaderboard) tablosu.

- [ ] **Sayfa 5 (Ayarlar & Profil):**
  - Profil kartı, avatar seçimi (hazır avatar seti veya cihazdan yükleme).
  - Hesap bilgileri güncelleme (E-posta, Telefon, Şifre kontrolleri).
  - Çift tema anahtarı (Koyu Tema - Varsayılan / Aydınlık Tema).
  - Çoklu dil seçimi (Türkçe - Varsayılan / İngilizce).

---

### 6.4. Veri Modelleri ve İmmutable Tasarım

Her model `@immutable` olarak tanımlanır; `copyWith`, `fromJson` ve `toJson` metotlarına sahip olmalıdır:

- **Habit (Alışkanlık Modeli):**
  - `id`: String
  - `title`: String
  - `description`: String
  - `frequency`: String (örneğin: 'daily', 'weekdays', 'weekly')
  - `reminderTime`: String?
  - `streakCount`: int
  - `bestStreak`: int
  - `isCompletedToday`: bool
  - `completedDates`: List<String>
  - `category`: String

- **User (Kullanıcı Modeli):**
  - `id`: String
  - `name`: String
  - `email`: String
  - `phone`: String
  - `avatarUrl`: String
  - `totalPoints`: int
  - `currentRank`: String
  - `preferredLanguage`: String ('tr' / 'en')
  - `isDarkMode`: bool

- **Tournament / CommunityHabit (Turnuva ve Topluluk Alışkanlığı Modeli):**
  - `id`: String
  - `title`: String
  - `description`: String
  - `habitId`: String
  - `participantCount`: int
  - `leaderboard`: List<Map<String, dynamic>>
  - `startDate`: String
  - `endDate`: String
  - `rewardPoints`: int

- **AIInsight (Yapay Zeka Analiz Modeli):**
  - `id`: String
  - `userId`: String
  - `generatedSummary`: String
  - `suggestions`: List<String>
  - `createdAt`: String

---

### 6.5. Kırmızı Çizgiler -> Kod Kalite Standartları

1. **State Yönetim Standartları:**
   - Sayfa düzeyinde ve iş mantığı yönetiminde ağır `setState` **KULLANILMAYACAKTIR**.
   - İş mantığı ve state, ilgili özelliğin `controllers/<feature>_controller.dart` dosyasında `ValueNotifier<T>` ile yönetilecektir.
   - UI yalnızca `ValueListenableBuilder` kullanarak sadece değişen bölümü yeniden çizecektir.
   - Sadece yerel mikro arayüz durumunu yöneten (örneğin animasyon controller'ları, sayfa içi geçici tab index vb.) `StatefulWidget` kabul edilir.
   - Controller'lar bellek sızıntısını önlemek için mutlaka `dispose()` metoduna sahip olmalıdır.

2. **UI ve Performans Standartları:**
   - Statik tüm widget'larda **`const` zorunludur**.
   - Renk ve metin stilleri kesinlikle tema dosyalarına (`app_colors.dart`, `app_theme.dart`) yazılacaktır; arayüz kodlarında doğrudan hex kodları (hardcoded color) kullanılmayacaktır.
   - Büyük `build` metotları yasaktır. **40 satırı geçen `build` metotları** modüler alt widget'lara parçalanarak `widgets/` altına taşınacaktır.

3. **Yasaklı Paketler:**
   - Projeye onay almadan harici ağır state paketleri (**Bloc, Riverpod, MobX, GetX, Redux vb.**) **EKLENMEYECEKTİR**.
   - Dart'ın ve Flutter'ın yerel çekirdek API'lerini (`ValueNotifier`, `ChangeNotifier`, `InheritedWidget`) kullanmak esastır.

---

### 6.6. İkon, Splash Screen ve Test Verileri

- **İkon ve Açılış Ekranı (Splash Screen):**
  - Uygulama ikonu SVG olarak tasarlanır, platform gereksinimlerine göre PNG dosyaları üretilir ve `flutter_launcher_icons` ile tüm platformlara uygulanır.
  - Yerel açılış ekranı `flutter_native_splash` ile oluşturulur (Android 12+ standartlarına uygun).
  - Uygulama adı tüm platform yapılandırmalarında **"Rutino"** olarak ayarlanır.
- **Mock / Test Verileri:**
  - Uygulama ilk kez ayağa kaldırılırken veya test edilirken zengin örnek alışkanlıklar, geçmiş günlere ait seri (streak) verileri ve turnuva listesi içeren tohumlama (seeding) mekanizması sağlanmalıdır.

---

### 6.7. Geliştirme Analiz ve Test Komutları

Ajan, yaptığı herhangi bir kod değişikliğinden sonra mutlaka alttaki komutların başarıyla çalıştığını doğrulamalıdır:

- **Statik Kod Analizi (0 Uyarı ve 0 Hata Şartı):**
  ```bash
  flutter analyze
  ```

- **Birim ve Widget Testleri:**
  ```bash
  flutter test
  ```

- **Projeyi Çalıştırma:**
  ```bash
  flutter emulators && flutter devices
  flutter run -d <cihaz_id>
  ```

---

### 6.8. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.
- **DONE.md Güncelleme Zorunluluğu:** Yapılan her değişiklikten sonra (küçük düzeltmeler dahil) proje kökündeki `DONE.md` dosyası güncellenmelidir. En üstte `| Aşama | Durum |` tablosu, her adım başlığı `## [YYYY-MM-DD] Aşama X – Başlık` biçiminde, adım içinde sırasıyla `Yapılanlar`, `Dosyalar` (Oluşturulan/Güncellenen/Silinen olarak tek cümleyle), `Doğrulama`, `Alınan Kararlar`, `Açık Konular` ve sonda güncel `Final Özet` yer alacaktır.
- **Değişiklik Sunumları:** Örneğin 500 satırlık bir dosyada 3 satır değiştiyse tüm dosyayı baştan sona basma; hedef satırları ve diff yapısını göster.
- **Dosya Yolları:** Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanabilir bağlantı ver (örn: `[app_theme.dart](file:///path/to/app_theme.dart)`).
- **Doğrulama:** Kod yazdıktan sonra kullanıcıya `"Şimdi flutter analyze ile kontrol edebilirsin"` şeklinde doğrulama yönergeleri sağla.

---

### 6.9. Proje Takvimi ve Teslim Aşamaları

- **Aşama 1 (Tasarım & Wireframe):** Temel tema yapısı, 5 ana ekranın iskeletinin çıkarılması, kimlik doğrulama arayüzü.
- **Aşama 2 (Temel Fonksiyonlar & Alışkanlık Yönetimi):** Alışkanlık CRUD işlemleri, yerel depolama servisi, seri (streak) ve puanlama mantığı.
- **Aşama 3 (Analiz & Topluluk Turnuvaları):** Yapay zeka tavsiye motoru entegrasyonu, yerel bildirimler, otomatik turnuva ve liderlik tablosu.
- **Aşama 4 (Test, İyileştirme & Final Teslim):** Çift tema ve çoklu dil geçişi, edge case testleri, splash screen/ikon yapılandırması ve dağıtım hazırlığı.

---

### 6.10. Notlar & Karşılaşılan Zorluklar
<Geliştirme Esnasında Eklenen Notlar ve Çözüm Yolları> <Burayı Ben Dolduracağım, Elleme>
