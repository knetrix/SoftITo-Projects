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
| `image_picker`                                | Ayarlar'da Galeriden/Kameradan Profil Resmi, Manuel Kitap Eklemede Kapak Resmi Yükleme                                      |
| `http`                                        | Open Library API ile ISBN/Başlık Araması                                                                                    |
| `crypto`                                      | Şifrenin Düz Metin Yerine SHA-256 Hash Olarak Saklanması                                                                    |
| Open Library API                              | `https://openlibrary.org/search.json?q=` ve `https://openlibrary.org/isbn/<ISBN>.json` (Ücretsiz, API Anahtarı Gerektirmez) |
| Open Library Covers                           | `https://covers.openlibrary.org/b/isbn/<ISBN>-L.jpg` (Kitap Kapak Resimleri)                                                |
| `path_provider`                               | Dijital Kitap Metinlerinin Çevrimdışı Okuma için Uygulama Belgeler Klasörüne Dosya Olarak Kaydedilmesi                      |
| Project Gutenberg                             | `https://www.gutenberg.org/cache/epub/<ID>/pg<ID>.txt` (Telifi Bitmiş Dünya Klasiklerinin Düz Metni)                        |
| Vikikaynak (MediaWiki API)                    | `https://tr.wikisource.org/w/api.php` (Telifi Bitmiş Türkçe Eserlerin Metni)                                                |
| `file_picker`                                 | Kullanıcının Kendi PDF / EPUB Dosyasını Cihazdan Seçmesi                                                                    |
| `archive`                                     | EPUB (Zip) Dosyasının Açılıp Bölümlerinin Okuyucu Metnine Çevrilmesi (Saf Dart)                                            |
| `pdfrx`                                       | Kullanıcının PDF Dosyasının Orijinal Sayfa Düzeniyle Gösterilmesi (PDFium)                                                  |
| Google ML Kit (Android, Gradle: `com.google.mlkit:translate`, `com.google.mlkit:language-id`) | Android'de Okuyucudaki İngilizce ↔ Türkçe Cihaz Üstü Çeviri ve Yüklenen PDF / EPUB'un Dil Tanıması (Dil Paketi Bir Kez İndirilir, Sonra Çevrimdışı). Dart Paketi Değil, Uygulamanın Kendi Yerel Köprüsünden (`kitalog/translation`) Çağrılır |
| Apple `Translation` + `NaturalLanguage` (iOS 18+, Sistem Kütüphanesi) | iOS'ta Aynı Çeviri ve Dil Tanıma; Dil Paketini Sistem İndirir ve Onayını Kendi Penceresinde Sorar. Apple Çeviriyi Simülatörde Kapattığı için iOS Simülatöründe Çeviri Gizlenir |
| `flutter_local_notifications`                 | Ödünç Verilen Kitapların İade Hatırlatması ve Okuma Hatırlatmaları: Cihaz Üstü Zamanlanmış Bildirim (Yalnızca Android / iOS; Sunucu Gerekmez)       |
| `timezone`                                    | `flutter_local_notifications`'ın Zamanlama API'sinin İstediği `TZDateTime` (Tek Seferlik Bildirim UTC Anıyla Kurulur; Günlük Okuma Hatırlatması da Tekrar Eden Değil, 7 Günlük Tek Seferlik Bildirimlerle Kurulur)      |
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
                                     │     └─ Kitaba Dokun ► Kitap Detay & Alıntı ► Dijital Okuyucu
                                     ├─ Sekme 2: Okuma Durumu (Okunacak / Okunuyor / Bitti)
                                     │     └─ Kitaba Dokun ► Kitap Detay & Alıntı ► Dijital Okuyucu
                                     ├─ Sekme 3: Ödünç Takibi (Ödünçte / Geçmiş)
                                     │     ├─ FAB ► Ödünç Verilecek Kitabı Seç ► Ödünç Ver
                                     │     └─ Kitaba Dokun ► Kitap Detay & Alıntı
                                     ├─ Sekme 4: Yıllık Okuma Hedefi Paneli
                                     └─ Sağ Üst ⚙ ► Ayarlar (Profil, Tema, Dil, Hesap Bilgileri, Çıkış)
```



- [x] Sayfa 0 – Splash / Oturum Kontrolü: Yerel Açılış Ekranıyla (Bkz. 6.5) Aynı Zemin ve Logoyu Kullanır, Böylece Geçiş Kesintisiz Görünür. Kayıtlı Oturum Varsa Ana Kabuğa, Yoksa Kayıt Ekranına Yönlendirir. İlk Açılışta Örnek Kitap Verisini (Seed) Yükler.
- [x] Sayfa 1 – Kayıt &amp; Giriş: E-Posta, Telefon, Şifre (+ Şifre Tekrar) ile Kayıt; Mevcut Kullanıcı için E-Posta + Şifre ile Giriş (Bkz. 6.4). Girişte "Şifremi Unuttum" (GEÇİCİ, Yerel): Kayıtlı E-Posta + Telefon Eşleşirse Yeni Şifre Belirlenir (5 Hatalı Denemede 30 sn Bekleme); Tamamlanınca Girişe E-Posta Dolu Dönülür. İleride Firebase Auth Tarzı Bir Servise Geçilince Yalnızca `AuthController`'daki Doğrulama / Sıfırlama Yöntemleri Değişir.
- [x] Sayfa 2 – Kitaplığım (Raf Görünümü): Kitap Kapaklarının Raf/Grid Düzeninde Listelenmesi, Başlık/Yazar Araması ve Hemen Sağındaki "Filtreler" Düğmesiyle Açılan Panel: Biçim (Fiziksel / Dijital) ve Tür (Kullanıcı Kategorileri Dahil) Filtreleri Birden Fazla Seçilebilir (Okuma Durumuna Göre Ayırma "Okuma Durumu", Ödünçteki Kitapların Takibi "Ödünç Takibi" Sekmesindedir) (Grup İçinde "Veya", Gruplar Arası "Ve"); Seçili Filtre Sayısı Düğmede Rozetle, Seçimler Aramanın Altında Tek Dokunuşla Kaldırılabilen Çipler Olarak Görünür, Kapakta Biçim Rozetleri: Fiziksel Kopya Varsa "Fiziksel" (Kopya Ödünçteyse Onun Yerine "Ödünçte"), Dijital Sürüm Varsa "Dijital"; Yalnızca Dijital Olan Kitapta Sadece "Dijital".
- [x] Sayfa 3 – Yeni Kitap Ekle: ISBN ile Arama, Başlık/Yazar ile Arama (Open Library), Sonuç Bulunamazsa Manuel Form (Başlık, Yazar, Sayfa Sayısı, Tür, Kapak, Durum, "Bu Kitap Bende Fiziksel Olarak Var" Seçeneği). Kitabın Türü Listede Yoksa Tür Alanının Yanındaki "Yeni Kategori Ekle" ile Ad ve Renk Seçilerek Hızlıca Kategori Eklenir ve Seçili Gelir (Ad Benzersizdir; Yerleşik Türlerle de Çakışamaz). Kapak URL ile veya Cihazdan (Galeri / Kamera) Resim Seçilerek Eklenir; Cihazdan Seçilen Resim Küçültülüp `coverUrl` İçinde `data:image/...;base64` Olarak Saklanır.
- [x] Sayfa 4 – Okuma Durumu: Soldan Sağa Okunacak / Okunuyor / Bitti Sekmeleri (Açılışta Okunuyor Seçili); Okunuyor Kartlarında İlerleme Çubuğu, Sayfa ve Yüzde. Sayfa, Karta Dokununca Açılan Kitap Detay'ın Okuma İlerlemesi'nden Değiştirilir.
- [x] Sayfa 5 – Kitap Detay &amp; Alıntı: Kapak, Künye, Tür Etiketi, Sayfa Sayacı &amp; İlerleme Çubuğu, Durum Değiştirme, Puan (1-5) &amp; Şahsi İnceleme, Alıntılar (Sayfa No ile, Favori İşaretleme), Notlar, Ödünç Verme Bilgisi (Kime, Ne Zaman, İade Tarihi; Yalnızca Fiziksel Kopyası Olan Kitapta Görünür).
- [x] Sayfa 6 – Yıllık Okuma Hedefi Paneli: Yıllık Hedef Kitap Sayısı Belirleme, İlerleme Çubuğu (Biten / Hedef), Aylık Biten Kitap Dağılımı, Toplam Okunan Sayfa, Türlere (Kullanıcı Kategorileri Dahil) Göre Dağılım.
- [x] Sayfa 7 – Ayarlar: Profil Resmi &amp; Kullanıcı Özeti, Tema, Dil, Bildirimler ("İade hatırlatmaları", "Günlük okuma hatırlatması" ve "Yarım kalan kitaplar" Anahtarları ile "Okuma hatırlatması saati" (Sistemin Saat Seçicisi; Okuma Anahtarlarından Biri Açıkken Etkin); Kapatınca O Türün Zamanlanmış Hatırlatmaları Silinir, Açınca Bildirim İzni İstenir, İzin Yoksa Telefon Ayarlarına Yönlendiren Mesaj; Yalnızca Android / iOS'ta Görünür. Ayrıntı: Sayfa 10), E-Posta / Telefon / Şifre Güncelleme, Çıkış Yap (Bkz. 6.4).
- [x] Sayfa 9 – Ödünç Takibi (Sekme 3): Üstte Özet (Ödünçte / Gecikmiş / İadesi Yaklaşan – Bugün ile 3 Gün Arası), Altında "Ödünçte" ve "Geçmiş" Sekmeleri. Ödünçte: Fiziksel Kopyası Ödünç Verilmiş Kitaplar En Acil Olan Başta (Gecikenler, Sonra İade Günü Yaklaşanlar, En Sonda İade Tarihi Olmayanlar); Kartta Kime, Veriliş Tarihi ve Kaç Gündür Ödünçte Olduğu, İade Tarihi ve Durum Etiketi ("X Gün Gecikti" / "Bugün İade Edilmeli" / "İadeye X Gün Kaldı" / "İade Tarihi Yok"), "Düzenle" (Kime ve İade Tarihi; Veriliş Tarihi Korunur) ve Onaylı "İade Alındı". Geçmiş: İadesi Alınan Ödünçler En Son İade Başta (Kime, Veriliş – İade Tarihi, Süre, Geç İade Etiketi). FAB "Ödünç Ver" Yalnızca Fiziksel Kopyası Olan ve Ödünçte Olmayan Kitapları Aramalı Bir Panelde Listeler. İade Günü Gecikme Sayılmaz, Ertesi Gün Gecikmedir. Gecikmiş Ödünç Varsa Alt Çubuktaki "Ödünç" Sekmesinde Sayı Rozeti Görünür. Kitap Detay'daki Ödünç Bölümü Aynı Veriyi Kullanır; Oradan İade Alınan Kitap da Geçmişe Eklenir. İade Hatırlatması: İade Tarihi Olan Her Ödünç için İade Gününden Bir Gün Önce ("Yarın iade günü") ve İade Günü ("Bugün iade günü") Saat 10:00'da Cihaz Bildirimi Zamanlanır (Ödünç Verildiği Gün "Yarın" Hatırlatması Kurulmaz; Android Esnek Zamanlamayla 10:00-11:00 Arasında Gösterir). Ödünç Verme / Düzenleme / İade ve Dil Değişikliğinde Plan Yeniden Kurulur; Bildirim İzni Açılışta Değil, Kullanıcı İlk Kez İade Tarihli Bir Ödünç Kaydettiğinde İstenir. Hatırlatmaya Dokununca (Uygulama Açıkken, Arka Plandayken veya Kapalıyken) İlgili Kitabın Kitap Detay'ı Açılır; Oturum Kapalıysa Girişten Sonra Açılır, Kitap Silinmişse Yok Sayılır. Ayarlar'daki "İade hatırlatmaları" Anahtarı Kapalıyken Hiç Hatırlatma Kurulmaz. Web ve Masaüstünde Hatırlatma Yoktur.
- [x] Sayfa 8 – Dijital Okuyucu: Kitabın Telifi Bitmiş Dijital Metninin İndirilip Çevrimdışı Okunması (Türkçe Eserler Vikikaynak, Dünya Klasikleri Project Gutenberg), Sayfalı Okuma, Yazı Boyutu, Kalınan Yerin Saklanması, Okuma İlerlemesinin Sayfa Sayacına Otomatik Yansıması. Okuyucunun Sayfa Sayısı Her Zaman Kitabın Sayfa Sayısına (`BookModel.pageCount`) Eşittir: Metin Kitabın Sayfa Sayısı Kadar Sayfaya Bölünür, Okuyucudaki "Sayfa N" Sayaçtaki N ile Aynıdır; PDF'te, Sayfa Sayısı Bilinmeyen Kitapta ve Bu Sayıya Bölünemeyecek Kadar Kısa Metinde Kitabın Sayfa Sayısı Okuyucunun Sayfalarına Eşitlenir. Kullanıcı PDF / EPUB Yüklediğinde (veya Dosyayı Değiştirdiğinde) Kitabın Sayfa Sayısı Hemen Dosyanınkine Eşitlenir, İlerleme Yüzdesi Korunur: PDF'te Gerçek Sayfa Sayısı, EPUB'da Dosyadaki Basılı Sayfa Listesi (`page-list` / NCX `pageList`), Yoksa Okuyucunun Sayfa Sayısı. Okuyucu Yalnızca "Okunuyor" Durumundaki Kitapta Sayaçtaki Sayfadan Açılır; "Okunacak" ve "Bitti" Durumundaki Kitaplar Her Zaman İlk Sayfadan Açılır. Okurken Seçilen Metin, Seçim Menüsündeki "Alıntı Olarak Kaydet" ile Okuyucudaki Sayfa Numarasıyla Kaydedilir ve Kitap Detay'daki Alıntılar Bölümüne Otomatik Eklenir (Aynı Sayfadaki Aynı Metin Tekrar Eklenmez; PDF Kopyalamaya İzin Vermiyorsa Düğme Gösterilmez). Kullanıcının Eklediği (Dijital Sürümü Olmayan) Kitaplarda Kendi PDF / EPUB Dosyasını Yükleyip Okuması: EPUB Okuyucuda Metin Olarak, PDF Orijinal Sayfalarıyla Açılır; Dosya Yalnızca Cihazda Saklanır, DRM'li Dosyalar Açılmaz. İngilizce Kitaplar Türkçeye, Türkçe Kitaplar İngilizceye Cihaz Üstünde (Android'de Google ML Kit, iOS'ta Apple Translation) Çevrilir: Metin Okuyucuda Üst Çubuktaki Çeviri Menüsünden Orijinal / Çeviri / Orijinal ve Çeviri Alt Alta Görünümü Seçilir (Sayfa Numarası Değişmez, Satır ve Paragraf Yapısı Korunur, Sonraki Sayfa Önceden Hazırlanır); Metinde ve PDF'te Seçilen Metin, Seçim Menüsündeki "Çevir" ile Alttan Açılan Pencerede Çevrilir ("Kopyala", "Alıntı Olarak Kaydet"). İlk Çeviriden Önce Dil Paketinin İndirilmesi için Onay İstenir (Android'de Uygulamanın Penceresi, ~30 MB; iOS'ta Sistemin Kendi Penceresi); Sonra Çeviri İnternetsiz Çalışır. Çevrilen Satırlar Kitaba Ait Önbellek Dosyasında Saklanır (Dosya Değişince / Silinince Temizlenir). Yüklenen Dosyanın Dili Metinden Otomatik Tanınır; Dili İngilizce veya Türkçe Değilse ya da Platform Desteklemiyorsa (Web, Masaüstü, iOS Simülatörü) Çeviri Gösterilmez.
- [x] Sayfa 10 – Okuma Hatırlatmaları (Ayarlar > Bildirimler; İkisi de Varsayılan Kapalı, Saat Varsayılan 21:00): **Günlük Okuma Hatırlatması:** Önümüzdeki 7 Gün için Her Gün Seçilen Saatte Tek Seferlik Bildirim Kurulur; Plan Her Açılışta ve Her Değişiklikte İleri Kaydırılır (Uygulamayı Uzun Süre Açmayan Kullanıcıya Sonsuza Kadar Bildirim Gitmez). Metin "Okunuyor" Durumundaki En Son İlerlenen Kitaba Göre Üretilir ("“Kitap” kitabında N. sayfadasın. 10 dakika okumaya ne dersin?"); Okunan Kitap Yoksa Genel Davet. O Gün Sayfa İlerlemesi Kaydedildiyse O Günün Daveti Kalkar. Dün ve Öncesinde Art Arda En Az 2 Gün Okunduysa Başlık Seri Olur ("N gündür okuyorsun, seriyi bozma!"). **Yarım Kalan Kitaplar:** "Okunuyor" Kitapta Son İlerlemeden (Kayıt Yoksa Başlama Gününden) 14 Gün Sonra Seçilen Saatte Bir Kez Hatırlatılır; Aynı Günün Günlük Davetinin Yerini Alır. **Dokununca:** Kitabın Dijital Sürümü Varsa Okuyucu (Geri Gelince Kitap Detay), Yoksa Kitap Detay; Okunan Kitap Yoksa Okuma Durumu Sekmesi. Okuma Hatırlatmaları Android'de Ayrı Bir Kanaldadır ("Okuma hatırlatmaları"), İade Hatırlatmalarından Bağımsız Kapatılabilir. Web ve Masaüstünde Hatırlatma Yoktur.

### 6.3. Veri Modeli ve Bileşen Tasarımı

Tüm Modeller `@immutable`, Tüm Alanlar `final`'dır ve `copyWith`, `fromJson`, `toJson` Metotlarını Eksiksiz İçerir. Birden Fazla Feature Tarafından Kullanılan Modeller `lib/core/models/` Altında Tutulur.

**Enum'lar**


| Enum            | Değerler                                                                                                                                                                                                                                                                                             |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadingStatus` | `toRead` (Okunacak), `reading` (Okunuyor), `finished` (Bitti)                                                                                                                                                                                                                                        |
| `BookGenre`     | `novel` (Roman), `science` (Bilim), `history` (Tarih), `philosophy` (Felsefe), `personalDevelopment` (Kişisel Gelişim), `sciFiFantasy` (Bilim Kurgu &amp; Fantastik), `biography` (Biyografi), `poetry` (Şiir), `children` (Çocuk), `other` (Diğer) – Her Türün Rengi `AppColors` İçinde Tanımlıdır. |
| `AvatarType`    | `none`, `preset` (Hazır Avatar), `custom` (Kullanıcının Yüklediği Resim)                                                                                                                                                                                                                             |
| `DigitalSource` | `gutenberg` (Project Gutenberg), `wikisource` (Vikikaynak), `localFile` (Kullanıcının Yüklediği PDF / EPUB)                                                                                                                                                                                                                                           |
| `DigitalFormat` | `text` (Okuyucuda Sayfalanan Metin: Gutenberg, Vikikaynak, EPUB), `pdf` (Orijinal Sayfalarıyla Gösterilen PDF)                                                                                                                                                                                        |


**Modeller**


| Model              | Alanlar                                                                                                                                                                                                | Not                                                                                                                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `UserModel`        | `id`, `email`, `phone`, `passwordHash`, `avatarType`, `avatarValue` (Hazır Avatar Anahtarı veya Dosya Yolu), `createdAt`                                                                               | Şifre Asla Düz Metin Saklanmaz.                                                                                                                                                            |
| `BookModel`        | `id`, `isbn?`, `title`, `authors` (`List<String>`), `coverUrl?`, `pageCount`, `currentPage`, `genre`, `customGenreId?`, `status`, `rating?` (1-5), `review?`, `isOwned`, `loan?`, `startedAt?`, `finishedAt?`, `addedAt`, `digitalEdition?` | `progress` (= `currentPage / pageCount`, 0.0-1.0) Hesaplanan Getter'dır, Saklanmaz. `currentPage` 0 ile `pageCount` Arasında Sınırlanır; `pageCount`'a Ulaşıldığı Anda (Kitap Detay, Okuma Durumu veya Okuyucu) "Bitti Olarak İşaretle" Düğmesinin Açtığı "Kitabı Bitirdin mi?" Onayı Kendiliğinden Açılır; Zaten Son Sayfadayken İleri Gitmek Öneriyi Yinelemez. `isOwned` Fiziksel Kopyanın Olduğunu Belirtir; Ödünç Yalnızca Fiziksel Kopya İçindir (`isLent` = `isOwned` ve `loan` Dolu). |
| `LoanModel`        | `borrowerName`, `lentAt`, `dueAt?`                                                                                                                                                                     | `BookModel.loan` Doluysa Kitap "Ödünçte" Sayılır. `daysUntilDue`, `isOverdue`, `daysOut` Takvim Günüyle Hesaplanan Getter/Metotlardır (Saat Yok Sayılır; İade Günü Gecikme Değildir).                                                                                                                                          |
| `LoanRecordModel`  | `id`, `bookId`, `borrowerName`, `lentAt`, `dueAt?`, `returnedAt`                                                                                                                                       | İadesi Alınmış Ödünç (Ödünç Geçmişi). Kitap İade Alınınca `BookModel.loan` Buraya Taşınır; `daysOut` ve `wasLate` Hesaplanır. Kitap Silinince Geçmişi de Silinir.                         |
| `QuoteModel`       | `id`, `bookId`, `text`, `page?`, `isFavorite`, `createdAt`                                                                                                                                             |                                                                                                                                                                                            |
| `NoteModel`        | `id`, `bookId`, `content`, `createdAt`, `updatedAt`                                                                                                                                                    |                                                                                                                                                                                            |
| `ReadingGoalModel` | `year`, `targetBookCount`                                                                                                                                                                              | Biten Kitap Sayısı `BookModel.finishedAt` Yılından Hesaplanır.                                                                                                                             |
| `AppSettingsModel` | `themeMode` (Varsayılan `dark`), `localeCode` (Varsayılan `tr`), `readerTextScale` (Varsayılan `1.0`), `loanRemindersEnabled` (Varsayılan `true`), `readingRemindersEnabled` / `stalledBookRemindersEnabled` (Varsayılan `false`), `readingReminderMinutes` (Gece Yarısından İtibaren Dakika, Varsayılan `1260` = 21:00)                                                                                                  |                                                                                                                                                                                            |
| `DigitalEditionModel` | `source` (`DigitalSource`), `sourceId` (Gutenberg Numarası, Vikikaynak Sayfa Başlığı veya Yüklenen Dosyanın Adı), `languageCode`, `format`                                                                                       | `BookModel.digitalEdition` Doluysa Kitap Dijital Olarak Okunabilir. `languageCode` Okuyucudaki Çevirinin Yönünü Belirler (`en` → `tr`, `tr` → `en`); Yüklenen Dosyada Metinden Tanınır, Tanınamazsa Boş Kalır. |
| `LoanReminderModel` | `bookId`, `kind` (`dueTomorrow` / `dueToday`), `scheduledAt` | Zamanlanan İade Hatırlatması; Saklanmaz, Ödünçlerden Hesaplanır (`LoanReminderController.plan`). Metin Zamanlanırken Uygulama Diline Göre Üretilir. |
| `ReadingLogEntryModel` | `bookId`, `day` (Takvim Günü), `pages` | Günlük Okuma Kaydı: Kitapta Sayfa İlerleyince (Kitap Detay veya Okuyucu) O Günün Kaydına Eklenir, Geri Gitmek Sayılmaz. 400 Günden Eskisi Silinir; Kitap Silinince Korunur (Seri Bozulmasın). |
| `ReadingReminderModel` | `kind` (`daily` / `streak` / `stalled`), `scheduledAt`, `bookId?`, `streakDays` | Zamanlanan Okuma Hatırlatması; Saklanmaz, Kitaplar + Okuma Kaydı + Ayarlardan Hesaplanır (`ReadingReminderController.plan`). |
| `NotificationTargetModel` | `kind` (`book` / `read` / `readingStatus`), `bookId?` | Bildirimin `payload`'ı (`book:<id>`, `read:<id>`, `readingStatus`); Önceki Sürümün Düz Kitap Kimliği Kitap Detay Sayılır. |
| `CustomGenreModel` | `id`, `name`, `colorIndex` (`AppColors.customGenrePalette` Sırası), `createdAt` | Kullanıcının Eklediği Kategori. `BookModel.customGenreId` Doluysa Etiket ve Renk Buradan Gelir, `genre` `other` Kalır; Kategori Bulunamazsa Kitap Yerleşik Türüne Düşer. |
| `DigitalCopyModel` | `bookId`, `fileName`, `charCount`, `downloadedAt`, `lastOffset`, `format`, `byteSize`, `textVersion`                                                                                                                                     | Cihaza İndirilmiş Metin; `lastOffset` Kalınan Yerin Karakter Konumudur. Metnin Kendisi `path_provider` ile Dosyada Tutulur.                                                                  |


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
| `kitalog.seedVersion` | Yüklü Örnek Verinin Sürümü (`int`) |
| `kitalog.digital`  | `List<DigitalCopyModel>` JSON   |
| `kitalog.genres`   | `List<CustomGenreModel>` JSON   |
| `kitalog.loanHistory` | `List<LoanRecordModel>` JSON |
| `kitalog.readingLog` | `List<ReadingLogEntryModel>` JSON |


**Katmanlı Veri Akışı**

```text
View / Widget ──(Aksiyon)──► Controller ──► Repository ──► LocalStorageService ──► SharedPreferences
      ▲                          │
      └──(ValueListenableBuilder)┴── ValueNotifier<State>
```

- `BookRepository`, `QuoteRepository`, `NoteRepository`, `GoalRepository`, `GenreRepository`, `LoanHistoryRepository`, `ReadingLogRepository`, `AuthRepository`, `SettingsRepository`, `BookSearchRepository`, `DigitalBookRepository`, `TranslationRepository` → `lib/core/repositories/`
- Bildirim Motoru `ReminderEngine` Arayüzünün Arkasındadır (`lib/core/repositories/reminders/`): Uygulama `flutter_local_notifications`'ı, Testler Sahte Motoru Kullanır. Bildirimler Gruplara Ayrılır (`ReminderGroup.loans` Kimlik 1-10000, `ReminderGroup.reading` 10001-20000; Her Grubun Kendi Android Kanalı Var); Bir Grubun Planı Yeniden Kurulurken (`replaceGroup`) Diğerine Dokunulmaz. `NotificationController` (`main.dart` Başlatır, `AppScope` Paylaşır) Motoru Bir Kez Hazırlar, Ardından `LoanReminderController` (İade) ve `ReadingReminderController` (Günlük Okuma, Seri, Yarım Kalan Kitap) Planlarını Başlatır; İkisi de Kitaplar Yüklenene Kadar Bekler, Plan Değişmediyse Bildirimlere Dokunmaz (Okuma Planında Yalnızca Metin Değiştiyse, Ör. Sayfa Çevirmek, 2 sn Bekleyip Bir Kez Kurulur). Dokunulan Bildirimin Hedefi `pendingTarget` ile Ana Kabuğa İletilir, Ana Kabuk Hedefi Açar.
- Çeviri Motoru `TranslationEngine` Arayüzünün Arkasındadır (`lib/core/repositories/translation/`): Uygulama `NativeTranslationEngine`'i (Yerel Köprü `kitalog/translation`: Android `TranslationChannel.kt` → Google ML Kit, iOS `TranslationChannel.swift` → Apple Translation + NaturalLanguage), Testler Sahte Motoru Kullanır; Motor `main.dart`'ta Yerel Tarafa Sorularak Seçilir, Desteklenmiyorsa Çeviri Gizlenir. Çeviri Önbelleği `<kitap>.<kaynak>-<hedef>.json` Dosyasında (`path_provider`), Satırın Özetiyle Tutulur.
- Uygulama Geneli Paylaşılan Controller'lar (`AuthController`, `LibraryController`, `SettingsController`, `NotificationController`) `AppScope` Üzerinden Sağlanır; Ekrana Özel Controller'lar (Örn: `AddBookController`) View İçinde Oluşturulup `dispose` Edilir.

**Ortak Bileşenler (`lib/core/widgets/`)**

- `BookCoverImage` (Network Kapak + Yükleniyor/Hata Durumunda Tür Renginde Yer Tutucu)
- `GenreChip` (Türe Göre Renkli Etiket)
- `ReadingProgressBar` (Yüzde ve Sayfa Bilgisiyle İlerleme Çubuğu)
- `RatingStars` (1-5 Puan Gösterimi / Seçimi)
- `EmptyStateView` (Boş Liste Mesajı)
- `LoanDialog` (Ödünç Verme / Düzenleme Penceresi; Kitap Detay ve Ödünç Takibi Ortak Kullanır)

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
- Şifre Güncellemede Mevcut Şifre Doğrulanır. Şifremi Unuttum'da Yeni Şifre de Aynı Validator'larla Doğrulanır. E-Posta Değişikliği Giriş Bilgisini de Günceller.
- Hazır Avatarlar `assets/avatars/` Altında Tutulur; Yüklenen Resim `image_picker` ile Seçilip Uygulama Dizinine Kopyalanır ve Yolu `UserModel.avatarValue`'ya Yazılır.
- Tema ve Dil Seçimi `SettingsController` Üzerinden Anında Uygulanır (`MaterialApp` `ValueListenableBuilder` ile Sarılır) ve Kalıcı Saklanır.
- Ayarlar Ekranında Ek Olarak "Çıkış Yap" Bulunur (Oturumu Kapatır, Veriler Silinmez, Giriş Ekranına Döner).

### 6.5 Ek Notlar

- Uygulamayı Test Etmek için / İlk Çalıştırırken Bol Sayıda Gerçek Kitap ve Kitaba Ait Resimler de Ekle.

**Teknik Karşılığı (Seed Data)**

- Örnek Veriler `lib/core/data/seed_data.dart` İçinde Tutulur ve `kitalog.seeded` Anahtarı `false` İken Sadece Bir Kez Yüklenir.
- En Az 30 Gerçek Kitap: Türk ve Dünya Edebiyatından Karışık, Tüm Türlerden En Az 2 Kitap. Tüm Örnek Kitaplar Telifi Bitmiş (Public Domain) Eserlerdir ve Dijital Olarak Okunabilir: Türkçe Eserler Vikikaynak'tan (Örn: Sabahattin Ali, Atatürk), Dünya Klasikleri Project Gutenberg'den (Örn: Dostoyevski, Austen, Shelley, Darwin, Marcus Aurelius). Vikikaynak'ta Tam Metni Olmayan Eserler ve Derlemeler Kullanılmaz.
- Kaynağından İndirilmesi Çok Uzun Süren Çok Parçalı Eserlerin (Örn: Nutuk) Metni `assets/books/` Altında Uygulamayla Birlikte Paketlenir; Bu Kitaplar İnternet Olmadan da Anında İndirilip Okunur.
- Örnek Veri Sürümü `kitalog.seedVersion` ile Tutulur; Sürüm Değiştiğinde Yalnızca Örnek Kitaplar (id'si `seed-` ile Başlayanlar) Yenilenir, Kullanıcının Eklediği Kitaplar Korunur.
- Her Kitabın Gerçek ISBN'i ve Open Library Kapak URL'i Bulunur (`https://covers.openlibrary.org/b/isbn/<ISBN>-L.jpg`). ISBN'ler Kodlama Aşamasında Doğrulanmalıdır, Uydurma ISBN YASAKTIR.
- Kitaplar 3 Okuma Durumuna Dağıtılır; Okunanlara Puan &amp; İnceleme, Okunuyor Olanlara Farklı İlerleme Yüzdeleri, En Az 3 Kitaba Ödünç Bilgisi (Biri Gecikmiş), En Az 3 İadesi Alınmış Ödünç Kaydı (Biri Geç İade), Toplam En Az 15 Gerçek Alıntı (Sayfa No ile; Alıntılar Dijital Metinde Birebir Doğrulanır) ve Birkaç Not Eklenir.
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
- **Aşama 5 (Dijital Okuma):** Dijital Sürüm Modelleri ve Çevrimdışı Dosya Depolama (`path_provider`) → Project Gutenberg ve Vikikaynak Metin Kaynakları → Telifi Bitmiş Kitaplarla Seed'in Yeniden Kurulması → Dijital Okuyucu Ekranı (Sayfalama, Yazı Boyutu, Kalınan Yer, İlerleme Senkronu) → Kitap Detay Entegrasyonu ve Dijital Sürüm Arama; Her Adımda Testler.

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
        reading_status/             # Okunacak / Okunuyor / Bitti
        book_detail/                # Detay, Alıntı, Not, İnceleme, Ödünç
        reading_goal/               # Yıllık Okuma Hedefi Paneli
        settings/                   # Profil, Tema, Dil, Hesap
        loans/                      # Ödünç Takibi (Ödünçte / Geçmiş, Ödünç Ver)
        reader/                     # Dijital Okuyucu (Çevrimdışı)
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
    books/                          # Uygulamayla Paketlenen Dijital Metinler (Örn: Nutuk)
    fonts/                          # Marka Yazı Tipi DM Serif Display (SIL OFL 1.1) ve Lisans Metni
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

- **Projeyi Çalıştırma**

> Uygulama Android Emülatöründe, iOS Simülatöründe ve Gerçek Cihazlarda Çalışır. Apple Cihaz Üstü Çeviriyi Simülatörde Kapattığı için iOS Simülatöründe Okuyucudaki Çeviri Gizlenir; Çeviriyi Denemek için Android Emülatörü (Örn: `flutter emulators --launch Pixel_8`) veya Gerçek iPhone Kullanılır. iOS En Düşük Sürümü 18.0'dır (Apple Translation Şartı).

```bash
flutter devices
flutter run -d <cihaz-id> (flutter devices Çıktısına Göre: iOS Simülatörü, Gerçek iPhone veya Android Emülatörü, Örn: emulator-5554)
```

## 10. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe, Teknik Terimlerin Özünü Bozmadan Net ve Doğrudan Olacaktır.
- **Değişiklik Sunumları:** Örneğin 500 Satırlık Bir Dosyada 3 Satır Değiştiyse Tüm Dosyayı Baştan Sona Basma; Hedef Satırları ve Diff Yapısını Göster.
- **Dosya Yolları:** Bahsedilen ve Üretilen Her Dosya için Mutlaka Projeye Göre Tıklanabilir Link Ver.
- **Doğrulama:** Kod Yazdıktan Sonra Kullanıcıya "Şimdi flutter analyze ile Kontrol Edebilirsin" Şeklinde Doğrulama Yönergeleri Ver.
- **Kapsam:** Kullanıcının İstemediği Feature'ları veya Paketleri Kendiliğinden Ekleme; Belirsiz Bir Karar Varsa Sor.