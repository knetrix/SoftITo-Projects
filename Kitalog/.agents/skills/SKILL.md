---
name: flutter-feature-scaffold
description: Kitalog Flutter Projesinde Yeni Bir Ekran veya Feature Modülü Açarken Kullanılır. Feature Bazlı Klasör Yapısını, ValueNotifier State Mimarisini, Tema/Çoklu Dil Uyumlu UI Katmanını ve Birim Test İskeletini PROJECT.md Standartlarına Uygun Olarak Üretir.
---

# Flutter Feature Scaffold (Modüler Ekran İskeleti) – Kitalog

Bu Yetenek, Kitalog Projesinde Yeni Bir Ekran veya İşlev Modülü Açarken Clean UI ve Reaktif State Kurallarına Tam Uyulmasını Garanti Altına Alır. Bağlayıcı Kurallar: [PROJECT.md](../../PROJECT.md) (Bölüm 7-10).

## Temel Kurallar

### Asla Tek Dosyada Toplama
UI (`_view.dart`), State Controller (`_controller.dart`), Model (`_model.dart`) ve Alt Widget (`_widget.dart`) Dosyaları Ayrı Açılmalıdır.

### State Management
- Reaktif Durumlar için `ValueNotifier<T>` + `ValueListenableBuilder` Kullanılır.
- Devasa `StatefulWidget`'lar ve Sayfa Düzeyinde `setState` YASAKTIR. View'daki `StatefulWidget` Sadece Controller Yaşam Döngüsünü (`initState` / `dispose`) Yönetir.
- Birden Fazla Ekranın Paylaştığı Veri (Kitaplar, Kullanıcı, Ayarlar) Feature Controller'ında Kopyalanmaz; `AppScope` Üzerinden Paylaşılan Controller'dan Okunur (Bkz. [references/state_flow.md](references/state_flow.md)).

### Veri Erişimi
- Controller `SharedPreferences`'a Doğrudan Erişmez; `lib/core/repositories/` Altındaki Repository'leri Kullanır.
- Paylaşılan Modeller (`BookModel`, `QuoteModel`, `NoteModel`, `UserModel`, `ReadingGoalModel`, Enum'lar) `lib/core/models/` Altındadır. Feature `models/` Klasörü Sadece O Ekranın UI State Modelini Tutar.

### Tema ve Çoklu Dil
- Renk ve Metin Stili Koda Gömülmez → `Theme.of(context)`, `AppColors`, `context.textTheme`.
- Kullanıcıya Görünen Metin Koda Gömülmez → `app_tr.arb` + `app_en.arb` + `context.l10n.<anahtar>`.

### Const Zorunluluğu
Mümkün Olan Tüm Widget ve Constructor'larda `const` Olmalıdır.

### 40 Satır Kuralı
40 Satırı Geçen `build` Metotları `widgets/` Altında Ayrı Widget Sınıflarına Bölünür.

## Adım Adım Uygulama Akışı

> Hızlı Yol: Proje Kökünden `bash .agents/skills/script/generate_feature.sh <feature_name>` Çalıştırılarak Adım 1-6 Otomatik Üretilir. Ardından İçerik Feature'a Göre Doldurulur.

### Adım 1: Klasör Yapısını Oluştur
Hedeflenen Modül Adını (snake_case, Örn: `book_detail`) `lib/features/<feature_name>` Altına Kur:

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
test/features/<feature_name>/
    <feature_name>_controller_test.dart
```

Kitalog Feature Listesi: `splash`, `auth`, `home_shell`, `library`, `add_book`, `reading_status`, `book_detail`, `reading_goal`, `settings`.

### Adım 2: Model Dosyasını Yaz
`models/<feature_name>_model.dart` Dosyası `@immutable` Olmalı ve `copyWith`, `fromJson`, `toJson` İçermelidir. Asenkron İşlem Varsa `ViewStatus` (`initial`, `loading`, `success`, `failure`) Taşır:

```dart
import 'package:flutter/foundation.dart';

@immutable
class BookDetailModel {
  final String bookId;
  final int currentPage;
  final int pageCount;
  final bool isSaving;

  const BookDetailModel({
    required this.bookId,
    required this.currentPage,
    required this.pageCount,
    this.isSaving = false,
  });

  double get progress =>
      pageCount > 0 ? (currentPage / pageCount).clamp(0.0, 1.0) : 0.0;

  BookDetailModel copyWith({
    String? bookId,
    int? currentPage,
    int? pageCount,
    bool? isSaving,
  }) {
    return BookDetailModel(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      pageCount: pageCount ?? this.pageCount,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  factory BookDetailModel.fromJson(Map<String, dynamic> json) {
    return BookDetailModel(
      bookId: json['bookId'] as String? ?? '',
      currentPage: json['currentPage'] as int? ?? 0,
      pageCount: json['pageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'pageCount': pageCount,
    };
  }
}
```

### Adım 3: Controller Dosyasını Yaz
`controllers/<feature_name>_controller.dart` İçinde İş Mantığını ve `ValueNotifier` Tanımlarını Oluştur. Sadece `foundation.dart` Import Edilir, UI Bağımlılığı Yoktur:

```dart
import 'package:flutter/foundation.dart';

import '../../../core/repositories/book_repository.dart';
import '../models/book_detail_model.dart';

class BookDetailController {
  BookDetailController({
    required BookRepository repository,
    required BookDetailModel initial,
  })  : _repository = repository,
        state = ValueNotifier<BookDetailModel>(initial);

  final BookRepository _repository;
  final ValueNotifier<BookDetailModel> state;

  void changePage(int delta) {
    final current = state.value;
    final next = (current.currentPage + delta).clamp(0, current.pageCount);
    state.value = current.copyWith(currentPage: next);
  }

  Future<void> saveProgress() async {
    state.value = state.value.copyWith(isSaving: true);
    await _repository.updateCurrentPage(
      state.value.bookId,
      state.value.currentPage,
    );
    state.value = state.value.copyWith(isSaving: false);
  }

  void dispose() {
    state.dispose();
  }
}
```

### Adım 4: View Dosyasını Yaz
`views/<feature_name>_view.dart` Dosyasında Controller'ın Sahibi Olan İnce Bir `StatefulWidget` Kullan; Reaktif Kısımları `ValueListenableBuilder` ile Sar:

```dart
import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/book_detail_controller.dart';
import '../models/book_detail_model.dart';
import '../widgets/page_counter_widget.dart';

class BookDetailView extends StatefulWidget {
  const BookDetailView({super.key, required this.initial});

  final BookDetailModel initial;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  BookDetailController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppScope bir InheritedWidget olduğu için initState yerine burada okunur.
    _controller ??= BookDetailController(
      repository: AppScope.of(context).bookRepository,
      initial: widget.initial,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookDetailTitle)),
      body: SafeArea(
        child: ValueListenableBuilder<BookDetailModel>(
          valueListenable: controller.state,
          builder: (context, state, _) {
            return PageCounterWidget(
              currentPage: state.currentPage,
              pageCount: state.pageCount,
              progress: state.progress,
              onIncrement: () => controller.changePage(1),
              onDecrement: () => controller.changePage(-1),
            );
          },
        ),
      ),
    );
  }
}
```

### Adım 5: Widget Dosyasını Yaz
`widgets/<feature_name>_widget.dart` (veya Anlamlı Bir İsim, Örn: `page_counter_widget.dart`) Dosyasında `const` Constructor'lı `StatelessWidget` Oluştur. Renk ve Stil Temadan Gelir:

```dart
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class PageCounterWidget extends StatelessWidget {
  const PageCounterWidget({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.progress,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int currentPage;
  final int pageCount;
  final double progress;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              context.l10n.pageProgress(currentPage, pageCount),
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove)),
                IconButton(onPressed: onIncrement, icon: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Adım 6: Dil Anahtarlarını ve Rotayı Ekle
- Kullanılan Her Metni `lib/l10n/app_tr.arb` ve `lib/l10n/app_en.arb` Dosyalarına Ekle (Parametreli Metinlerde `placeholders` Tanımla), Ardından `flutter gen-l10n` Çalıştır.
- Ekran Bir Rota ise `lib/core/routing/app_routes.dart` İçine Rota İsmini ve `onGenerateRoute` Karşılığını Ekle.

### Adım 7: Test İskeletini Yaz
`test/features/<feature_name>/<feature_name>_controller_test.dart` İçinde En Az Başlangıç State'ini ve Her Public Controller Metodunu Test Et:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/book_detail/controllers/book_detail_controller.dart';
import 'package:kitalog/features/book_detail/models/book_detail_model.dart';

import '../../fakes/fake_book_repository.dart';

void main() {
  late BookDetailController controller;

  setUp(() {
    controller = BookDetailController(
      repository: FakeBookRepository(),
      initial: const BookDetailModel(bookId: '1', currentPage: 10, pageCount: 100),
    );
  });

  tearDown(() => controller.dispose());

  test('changePage sayfa sayısını 0 ile pageCount arasında sınırlar', () {
    controller.changePage(500);
    expect(controller.state.value.currentPage, 100);
    controller.changePage(-500);
    expect(controller.state.value.currentPage, 0);
  });
}
```

### Adım 8: Doğrula
```bash
flutter gen-l10n
flutter analyze   # 0 Uyarı, 0 Hata
flutter test
```

## Clean Architecture Kurallarına Uyum

- **Separation of Concerns:** Model = Veri, Controller = İş Mantığı, View = Yaşam Döngüsü & Kompozisyon, Widget = Saf Görünüm.
- **Reusability:** Birden Fazla Feature'da Kullanılan Widget'lar (`BookCoverImage`, `GenreChip`, `ReadingProgressBar`, `RatingStars`) `lib/core/widgets/` Altına Taşınır.
- **Testability:** Controller'lar Bağımlılıklarını Constructor ile Alır; Testte Sahte (Fake) Repository Verilebilir.

## Kullanım Örnekleri

### Örnek 1: Rotadan Ekran Açma
```dart
Navigator.of(context).pushNamed(
  AppRoutes.bookDetail,
  arguments: book.id,
);
```

### Örnek 2: Ortak Widget Kullanımı
```dart
GenreChip(genre: book.genre); // Renk AppColors içindeki tür renginden gelir
```

## Ekstra İpuçları
- **Dependency Injection:** Controller'lar `AppScope` (InheritedWidget) veya Constructor Parametresi ile Verilir. GetIt / Provider Onaysız EKLENMEZ.
- **Navigation:** Çekirdek `Navigator` + İsimli Rotalar Kullanılır. go_router Onaysız EKLENMEZ.
- **Form Validasyonu:** Kayıt ve Ayarlar Ekranları Aynı `core/utils/validators.dart` Fonksiyonlarını Kullanır.
- **Yan Etkiler:** SnackBar / Dialog Gösterimi için View İçinde `state.addListener` Kancası Kullanılır, `builder` İçinde Gösterilmez.

## SSS

### Soru: Hangi Durumlarda Bu Yeteneği Kullanmalıyım?
**Cevap:** Yeni Bir Ekran veya İşlev Modülü (Örn: `reading_goal`, `add_book`) Oluştururken.

### Soru: Hangi Durumlarda Bu Yeteneği Kullanmamalıyım?
**Cevap:** Mevcut Bir Ekranı Güncellerken veya Küçük Bir Hata Düzeltmesi Yaparken. Bu Durumda Sadece Kurallara (PROJECT.md Bölüm 8) Uyulur.
