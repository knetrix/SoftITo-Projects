name: flutter-feature-scaffold
description: Tiknow Araç Kiralama Projesinde Feature Bazlı Kod Yazmak için Gerekli Klasör Yapısını Oluşturur. ValueNotifier State Mimarisini, shared_preferences Kalıcılığını, TR/EN Çoklu Dil ve Çift Tema Kurallarını, CustomPainter Harita/Grafik Desteğini ve UI Ayrımını Üretir.

# Flutter Feature Scaffold (Tiknow Modüler Mimari İskeleti)
Bu Yetenek, Tiknow projesinde yeni bir ekran veya modül (auth, rental_map, payment, active_rentals, settings) açarken Clean UI ve reaktif state kurallarına tam uyulmasını garanti altına alır. Ayrıntılı kurallar için `PROJECT.md` ve `references/state_flow.md` okunur.

## Temel Kurallar

### Asla Tek Dosyada Toplama
UI (`_view.dart`), State Controller (`_controller.dart`), Model (`_model.dart`) ve Parçalı Widget'lar (`widgets/`) kesinlikle ayrı dosyalarda bulunmalıdır.

### State Management
- Basit, hafif ve reaktif durum yönetimi için `ValueNotifier` kullanılır.
- Harici state paketi eklenmez (Bloc, Riverpod, GetX, Provider vb. yasak).
- Reaktif alanlar `ValueListenableBuilder` ile dinlenir; sayfa düzeyinde `setState` yok.

### Kalıcılık
- `shared_preferences` yalnızca `core/services/storage_service.dart` içinde kullanılır.
- Modeller `toJson`/`fromJson` ile kalıcılığa hazır olur; Controller state'i değiştirdikten sonra `StorageService` ile kaydeder.

### Çoklu Dil (TR/EN) ve Tema (Açık/Koyu)
- Ekranda sabit metin yazılmaz: `context.tr('anahtar')`; anahtarlar `core/constants/app_strings.dart` içinde hem `tr` hem `en` için eklenir.
- Renkler `Theme.of(context).colorScheme` veya `AppColors` üzerinden alınır; widget içinde `Colors.xxx` yasak. Yeni ekran açık ve koyu temada kontrol edilir.
- Ana renk turuncumsudur (`AppColors.primary`).

### Harita ve Grafikler
- Harici harita/grafik paketi eklenmez; İstanbul haritası, araç marker'ı ve kullanım çubukları `CustomPainter` ile çizilir.

### Const Zorunluluğu
Mümkün olan tüm widget'larda `const` zorunludur.

### Validasyon ve Fiyat Mantığı
- Form kuralları `core/utils/validators.dart` içinde, fiyat hesapları saf fonksiyon olarak model/controller katmanında yazılır ve `flutter test` ile test edilir.

---

## Adım Adım Uygulama Akışı

### Adım 1: Klasör Yapısı Oluşturma
Hedeflenen modül adını (Örn: `auth`, `rental_map`, `payment`, `active_rentals`, `settings`), `lib/features/<feature_name>` altına kur. Script ile hızlı kurulum:

```bash
bash .agents/skills/script/generate_feature.sh <feature_name>
```

```text
lib/features/<feature_name>/
    controllers/
        <feature_name>_controller.dart
    models/
        <feature_name>_model.dart
    views/
        <feature_name>_view.dart
    widgets/
        <feature_name>_widget.dart
```

### Adım 2: Model Dosyasını Oluşturma (`models/<feature_name>_model.dart`)
Model immutable olmalı, `copyWith`, `fromJson` ve `toJson` metotlarını içermelidir:

```dart
import 'package:flutter/foundation.dart';

@immutable
class VehicleModel {
  final String id;
  final String model;
  final String plate;
  final bool isAutomatic;
  final int fuelPercent;
  final double pricePerMinute; // TL/dk
  final double latitude;
  final double longitude;
  final String imageUrl;

  const VehicleModel({
    required this.id,
    required this.model,
    required this.plate,
    required this.isAutomatic,
    required this.fuelPercent,
    required this.pricePerMinute,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      model: json['model'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      isAutomatic: json['isAutomatic'] as bool? ?? false,
      fuelPercent: json['fuelPercent'] as int? ?? 0,
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'plate': plate,
        'isAutomatic': isAutomatic,
        'fuelPercent': fuelPercent,
        'pricePerMinute': pricePerMinute,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
      };
}
```

Gerçek modellerde `copyWith` da eklenir (bkz. `examples/sample_screen.dart`).

### Adım 3: Controller Dosyasını Yazma (`controllers/<feature_name>_controller.dart`)
`ValueNotifier` ile state dışa aktarılır, kalıcılık `StorageService` ile yapılır. Flutter UI bağımlılığı içermez:

```dart
import 'package:flutter/foundation.dart';
import '../../../core/services/storage_service.dart';
import '../models/active_rental_model.dart';

class ActiveRentalsController {
  ActiveRentalsController(this._storage)
      : rentals = ValueNotifier<List<ActiveRentalModel>>(_storage.loadRentals());

  final StorageService _storage;
  final ValueNotifier<List<ActiveRentalModel>> rentals;

  void add(ActiveRentalModel rental) {
    rentals.value = [...rentals.value, rental];
    _storage.saveRentals(rentals.value);
  }

  void dispose() => rentals.dispose();
}
```

### Adım 4: View Dosyasını Oluşturma (`views/<feature_name>_view.dart`)
Görünüm katmanı Controller'ı dinler ve yalnızca değişen widget alanını günceller. Metinler `context.tr` ile gelir:

```dart
ValueListenableBuilder<List<ActiveRentalModel>>(
  valueListenable: controller.rentals,
  builder: (context, rentals, _) {
    if (rentals.isEmpty) {
      return Center(child: Text(context.tr('no_active_rentals')));
    }
    return ListView.builder(
      itemCount: rentals.length,
      itemBuilder: (_, i) => ActiveRentalCardWidget(rental: rentals[i]),
    );
  },
)
```

Dışarıdan verilen uygulama geneli controller view'da dispose edilmez; view'ın kendi oluşturduğu controller edilir.

### Adım 5: CustomPainter ile Harita/Grafik Widget'ı (`widgets/*_painter.dart`)
Harici paket yerine `CustomPainter`. Marker konumları enlem/boylamdan harita alanına normalize edilir; `shouldRepaint` yalnızca veri veya renk değişince `true` döner:

```dart
class VehicleMarkerPainter extends CustomPainter {
  const VehicleMarkerPainter({required this.points, required this.color});

  final List<Offset> points; // 0..1 normalize edilmiş konumlar
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(Offset(p.dx * size.width, p.dy * size.height), 14, paint);
    }
  }

  @override
  bool shouldRepaint(covariant VehicleMarkerPainter old) =>
      old.points != points || old.color != color;
}
```

Marker dokunuşu için `GestureDetector.onTapUp` içinde dokunma noktası en yakın marker ile eşleştirilir (yarıçap 24 dp).

### Adım 6: Clean Architecture & Kodlama Standartları
- **Separation of Concerns:** Her dosyanın tek bir görevi olmalıdır.
- **Micro Widgets:** 40 satırı geçen `build` parçaları `widgets/` altına taşınır.
- **Paket Disiplini:** İzinli paketler `shared_preferences`, `crypto`, `flutter_launcher_icons` (dev). Diğerleri için önce onay.
- **Doğrulama:** Her değişiklikten sonra `flutter analyze` (0 uyarı) ve `flutter test`.
