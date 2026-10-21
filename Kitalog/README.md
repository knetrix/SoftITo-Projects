# Kitalog

Kitaplarını, okuma durumunu, alıntılarını, notlarını ve yıllık okuma hedefini takip ettiğin; telifi bitmiş kitapları uygulama içinde **çevrimdışı okuyabildiğin** kişisel sanal kütüphane. Flutter ile yazılmıştır; veriler cihazda (`shared_preferences`), indirilen kitap metinleri uygulama klasöründe dosya olarak saklanır.

| Kitaplığım | Okuma Durumu | Yıllık Hedef |
| --- | --- | --- |
| ![Kitaplığım](docs/screenshots/02-library.png) | ![Okuma Durumu](docs/screenshots/04-reading.png) | ![Yıllık Hedef](docs/screenshots/05-goal.png) |

| Kitap Detay | Yeni Kitap Ekle | Ayarlar |
| --- | --- | --- |
| ![Kitap Detay](docs/screenshots/06-detail.png) | ![Yeni Kitap Ekle](docs/screenshots/07-add.png) | ![Ayarlar](docs/screenshots/08-settings.png) |

| Dijital Okuyucu | Çevrimdışı Okuma | Dijital Sürüm |
| --- | --- | --- |
| ![Dijital Okuyucu](docs/screenshots/10-reader.png) | ![Çevrimdışı Okuma](docs/screenshots/11-reader-offline.png) | ![Dijital Sürüm](docs/screenshots/12-detail-digital.png) |

| Kendi PDF'in | Kendi EPUB'ın | Dosya Yükleme |
| --- | --- | --- |
| ![PDF](docs/screenshots/13-reader-pdf.png) | ![EPUB](docs/screenshots/14-reader-epub.png) | ![Kendi Dosyan](docs/screenshots/15-detail-own-file.png) |

Ek görüntüler: [Giriş / Kayıt](docs/screenshots/01-register.png) · [Aydınlık tema](docs/screenshots/03-library-light.png) · [İngilizce](docs/screenshots/09-goal-en.png)

## Özellikler

- Kayıt / giriş (e-posta, maskeli telefon `0 (5XX) XXX XX XX`, güçlü şifre; şifre SHA-256 özeti olarak saklanır)
- Raf görünümünde kitaplık, tür/durum filtresi, başlık-yazar araması, ödünç rozeti
- Kitap detayı: sayfa sayacı, ilerleme, puan, inceleme, alıntılar (favori), notlar, ödünç bilgisi
- Okunuyor / Okunacak / Bitti sekmeleri ve hızlı sayfa sayacı
- Open Library ile ISBN / başlık araması veya manuel ekleme
- Yıllık okuma hedefi, aylık ve türe göre dağılım
- **Dijital okuma:** telifi bitmiş kitaplar Project Gutenberg (dünya klasikleri) ve Vikikaynak'tan (Türkçe eserler) indirilip internetsiz okunur; sayfalı okuyucu, yazı boyutu, kalınan yerden devam, ilerlemenin sayfa sayacına ve yıllık hedefe otomatik yansıması
- **Kendi PDF / EPUB dosyan:** kendi eklediğin kitaplara cihazından PDF veya EPUB yükleyip okuyabilirsin; EPUB okuyucuda metin olarak (yazı boyutu, kalınan yer), PDF orijinal sayfalarıyla açılır. Dosya yalnızca cihazında saklanır; kopya korumalı (DRM) dosyalar desteklenmez
- Koyu ("Gece Kütüphanesi") ve aydınlık ("Kağıt") tema, Türkçe / İngilizce
- İlk açılışta 31 telifi bitmiş, dijital okunabilir kitaplık örnek veri (doğrulanmış ISBN, kapak, Gutenberg/Vikikaynak kaynağı ve metinde doğrulanmış alıntılar)

## Kurulum ve çalıştırma

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run            # bağlı cihaz / simülatör
```

İkon veya açılış ekranı dosyaları değişirse:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Mimari

Feature bazlı klasörler (`controllers/`, `models/`, `views/`, `widgets/`); state `ValueNotifier` + `ValueListenableBuilder`, bağımlılıklar çekirdek `InheritedWidget` tabanlı `AppScope` ile paylaşılır. Harici state/DI/router paketi yoktur. Ayrıntılar: [PROJECT.md](PROJECT.md), [.agents/skills/SKILL.md](.agents/skills/SKILL.md). Geliştirme günlüğü ve kararlar: [DONE.md](DONE.md).

## Notlar

- Kapak ve arama verisi [Open Library](https://openlibrary.org) API'sinden gelir; internet yoksa kapaklar tür renginde başlıklı yer tutucuya düşer.
- Kitap metinleri [Project Gutenberg](https://www.gutenberg.org) ve [Vikikaynak](https://tr.wikisource.org) kaynaklıdır (telifi bitmiş eserler; uygulama kaynak atfını gösterir). Vikikaynak isteklerinde Wikimedia'nın istek sınırlarına uyulur. Kaynağından indirilmesi çok uzun süren Nutuk (~109 istek) uygulamayla birlikte paketlenir (`assets/books/`); internetsiz de anında açılır. Web sürümünde metinler yalnızca oturum boyunca saklanır.
- iOS'ta galeri/kamera izin metinleri `ios/Runner/Info.plist` içindedir.
