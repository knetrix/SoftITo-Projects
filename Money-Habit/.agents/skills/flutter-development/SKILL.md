---
name: flutter-development
description: >
  Money Habit Tracker Flutter projesinde genel geliştirme kılavuzu. Material 3
  (Dark varsayılan / Light) tema, ValueNotifier tabanlı state yönetimi, çekirdek
  Navigator ile isimli rotalar, SharedPreferences ile yerel depolama, TR/EN
  çoklu dil (gen-l10n), form validasyonu ve kuruş bazlı para hesapları. Ekran,
  widget, tema, rota, depolama veya l10n ile ilgili her kod işinde kullanılır.
---

# Flutter Development (Money Habit Tracker)

## İçindekiler

- [Genel Bakış](#genel-bakış)
- [Ne Zaman Kullanılır](#ne-zaman-kullanılır)
- [Hızlı Başlangıç](#hızlı-başlangıç)
- [Referans Kılavuzlar](#referans-kılavuzlar)
- [En İyi Uygulamalar](#en-i̇yi-uygulamalar)

## Genel Bakış

Bu Skill, `PROJECT_NEW.md` Dosyasındaki Bağlayıcı Kuralların Kod Seviyesindeki Karşılığıdır. Çelişki Olursa `PROJECT_NEW.md` Geçerlidir.

- **State:** `ValueNotifier` + `ValueListenableBuilder` (Provider / BLoC / Riverpod / GetX YOK)
- **Navigasyon:** Çekirdek `Navigator` + `AppRouter.onGenerateRoute` (go_router YOK)
- **Depolama:** `shared_preferences` → Sadece `LocalStorageService` Üzerinden
- **Ağ:** Uygulamada Backend Yok; `http` / `dio` Kullanılmaz
- **Dil:** `flutter_localizations` + `intl` + `flutter gen-l10n` (TR Varsayılan, EN)
- **Para:** `int` Kuruş; Gösterim `NumberFormat.currency(locale, symbol: '₺')`

## Ne Zaman Kullanılır

- Yeni Ekran, Widget, Form veya Grafik Yazarken
- Tema (`AppColors`, `AppTheme`), Rota (`AppRouter`) veya l10n (ARB) Değişikliklerinde
- `LocalStorageService` veya Model Serileştirme (`toJson` / `fromJson`) İşlerinde
- Sıfırdan Yeni Feature Klasörü Açılacaksa Önce `flutter-feature-scaffold` Skill'i Kullanılır, Sonra Bu Skill ile Doldurulur.

## Hızlı Başlangıç

```yaml
# pubspec.yaml (Sadece Beyaz Listedeki Paketler)
name: money_habit_tracker
environment:
  sdk: ^3.13.5

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any            # flutter_localizations'ın sabitlediği sürüm kullanılır
  shared_preferences: ^2.3.0
  image_picker: ^1.1.0
  path_provider: ^2.1.0
  crypto: ^3.0.0

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/avatars/
```

```dart
// lib/main.dart -> Sadece Başlatma
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.init();
  runApp(MoneyHabitApp(storage: storage));
}
```

> `app.dart`, `AppRouter` ve Klasör Yapısının Tamamı için: [Project Structure & Navigation](references/project-structure-navigation.md)

## Referans Kılavuzlar

| Kılavuz | İçerik |
|---|---|
| [Project Structure & Navigation](references/project-structure-navigation.md) | Klasör Yapısı, `app.dart`, `AppRouter`, Oturuma Göre Açılış Rotası, Tema / Dil Bağlantısı, `l10n.yaml` |
| [State Management with ValueNotifier](references/state-management-with-valuenotifier.md) | `LocalStorageService`, Immutable Model, Kuruş Bazlı Para, Controller + Kalıcılık (Harcama / Bütçe Örneği) |
| [Screens with ValueNotifier](references/screens-with-valuenotifier.md) | View Yaşam Döngüsü, `ValueListenableBuilder`, Form Validasyonu (Kayıt), Klavye Tipleri, Ayarlar İkonu |
| [Component Template](templates/component_template.dart) | Yeni Ortak / Feature Widget'ı için `const` StatelessWidget Şablonu |

## En İyi Uygulamalar

### ✅ YAP

- Her Statik Widget'ta `const` Constructor Kullan, `super.key` Yaz.
- Renkleri `AppColors` / `Theme.of(context).colorScheme`, Metin Stillerini `Theme.of(context).textTheme` Üzerinden Al.
- Tüm Kullanıcı Metinlerini ARB'ye Ekle ve `context.l10n.xxx` ile Kullan (TR ve EN Birlikte Güncellenir).
- Controller'ı `initState`'te Oluştur, `dispose`'ta Kapat.
- Durumu Değiştirmek için `state.value = state.value.copyWith(...)` Kullan (Liste Mutasyonu Değil, Yeni Liste).
- Para Tutarlarını `int` Kuruş Tut; Formdan Gelen `"125,50"` Değerini Controller'da Kuruşa Çevir.
- Kayıt ve Ayarlar Formlarında `core/utils/validators.dart` İçindeki Ortak Validator'ları Kullan.
- Uygun Klavye Tipi (`emailAddress`, `phone`, `numberWithOptions(decimal: true)`) ve `inputFormatters` Ver.
- Boş Durumlar için `EmptyStateWidget`, Uzun Listeler için `ListView.builder` Kullan.
- Validator ve Controller Hesaplamaları için Birim Testi Yaz.

### ❌ YAPMA

- 40 Satırı Aşan `build()` Metodu Yazma; Parçaları `widgets/` Altına Böl.
- Sayfa Düzeyinde `setState` ile İş Mantığı Yönetme.
- `build()` İçinde Depolama Okuma / Yazma veya Ağır Hesap Yapma.
- `SharedPreferences.getInstance()` Çağrısını View / Widget İçinde Yapma.
- `Colors.red`, `Color(0xFF...)`, `TextStyle(fontSize: ...)` Gibi Değerleri Widget İçine Gömme.
- Hardcoded String Yazma (`Text('Harcamalar')` YASAK → `Text(context.l10n.expensesTitle)`).
- Para için `double` Kullanma, Şifreyi Düz Metin Saklama.
- Onaysız Paket Ekleme (Bkz. `PROJECT_NEW.md` 6.1 Beyaz Liste).
- Değişiklikten Sonra `flutter analyze` ve `flutter test` Çalıştırmadan İşi Bitmiş Sayma.
