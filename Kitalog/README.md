# Kitalog

Kitaplarını, okuma durumunu, alıntılarını, notlarını ve yıllık okuma hedefini takip ettiğin kişisel sanal kütüphane. Flutter ile yazılmıştır; tüm veriler cihazda (`shared_preferences`) JSON olarak saklanır.

| Kitaplığım | Okuma Durumu | Yıllık Hedef |
| --- | --- | --- |
| ![Kitaplığım](docs/screenshots/02-library.png) | ![Okuma Durumu](docs/screenshots/04-reading.png) | ![Yıllık Hedef](docs/screenshots/05-goal.png) |

| Kitap Detay | Yeni Kitap Ekle | Ayarlar |
| --- | --- | --- |
| ![Kitap Detay](docs/screenshots/06-detail.png) | ![Yeni Kitap Ekle](docs/screenshots/07-add.png) | ![Ayarlar](docs/screenshots/08-settings.png) |

Ek görüntüler: [Kayıt](docs/screenshots/01-register.png) · [Aydınlık tema](docs/screenshots/03-library-light.png) · [İngilizce](docs/screenshots/09-goal-en.png)

## Özellikler

- Kayıt / giriş (e-posta, maskeli telefon `0 (5XX) XXX XX XX`, güçlü şifre; şifre SHA-256 özeti olarak saklanır)
- Raf görünümünde kitaplık, tür/durum filtresi, başlık-yazar araması, ödünç rozeti
- Kitap detayı: sayfa sayacı, ilerleme, puan, inceleme, alıntılar (favori), notlar, ödünç bilgisi
- Okunuyor / Okunacak / Bitti sekmeleri ve hızlı sayfa sayacı
- Open Library ile ISBN / başlık araması veya manuel ekleme
- Yıllık okuma hedefi, aylık ve türe göre dağılım
- Koyu ("Gece Kütüphanesi") ve aydınlık ("Kağıt") tema, Türkçe / İngilizce
- İlk açılışta 36 gerçek kitaplık (doğrulanmış ISBN ve kapak) örnek veri

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
- iOS'ta galeri/kamera izin metinleri `ios/Runner/Info.plist` içindedir.
