# Kitalog – Tamamlanan İşler (DONE)

## Durum Tablosu

| Aşama | Durum |
| --- | --- |
| Aşama 1 – Tasarım & Altyapı | Tamamlandı |
| Aşama 2.1 – Splash + Kayıt/Giriş + Oturum | Tamamlandı |
| Aşama 2.2 – Kitaplığım + Seed Data | Tamamlandı |
| Aşama 2.3 – Kitap Detay & Alıntı | Tamamlandı |
| Aşama 2.4 – Okuma Durumu | Tamamlandı |
| Aşama 2.5 – Yeni Kitap Ekle | Tamamlandı |
| Aşama 2.6 – Yıllık Hedef Paneli | Tamamlandı |
| Aşama 2.7 – Ayarlar | Tamamlandı |
| Aşama 3 – Test & İyileştirme | Tamamlandı |
| Aşama 4 – Final Teslim | Tamamlandı |

---

## [2026-10-21] Aşama 1 – Tasarım & Altyapı

- Yapılanlar:
  - `flutter create --project-name kitalog --org com.knetrix .` çalıştırıldı; mevcut `PROJECT.md` ve `.agents/` dokunulmadan korundu.
  - Onaylı paketler eklendi: `shared_preferences`, `intl`, `flutter_localizations`, `http`, `crypto`, `image_picker`; `dev`: `flutter_launcher_icons`, `flutter_native_splash`. `flutter create`'in getirdiği `cupertino_icons` kullanılmadığı ve onaylı listede olmadığı için kaldırıldı.
  - Klasör iskeleti (`core/`, `features/`, `l10n/`), `AppColors` (Gece Kütüphanesi / Kağıt paletleri + 10 tür rengi), `AppSizes`, `StorageKeys`, `AppTheme` (Material 3, koyu varsayılan).
  - ARB altyapısı (`l10n.yaml`, `app_tr.arb` şablon, `app_en.arb`) ve `context.l10n / colors / textTheme` extension'ları.
  - Modeller (`@immutable`, `copyWith/fromJson/toJson`): `UserModel`, `BookModel`, `LoanModel`, `QuoteModel`, `NoteModel`, `ReadingGoalModel`, `AppSettingsModel`; enum'lar `ReadingStatus`, `BookGenre`, `AvatarType`, `ViewStatus`.
  - `LocalStorageService` (SharedPreferences'a tek erişim noktası) ve 6 repository.
  - Paylaşılan controller'lar (`AuthController`, `LibraryController`, `SettingsController`), `AppScope` + `AppDependencies`.
  - `Validators` (e-posta, telefon, şifre, şifre tekrar), `PhoneInputFormatter` (`0 (5XX) XXX XX XX`).
  - Ortak widget'lar: `BookCoverImage`, `GenreChip`, `ReadingProgressBar`, `RatingStars`, `EmptyStateView`.
  - Seed verisi (`seed_data.dart`): 36 kitap, 23 alıntı, 4 not, 4 ödünç, 24 kitaplık hedef. Tüm ISBN'ler Open Library API'sinden (`/isbn/<ISBN>.json` + kapak 200 yanıtı) ve ISBN-13 sağlama toplamıyla doğrulandı.
  - Uygulama ikonu SVG olarak tasarlandı, `rsvg-convert` ile PNG'lere dönüştürüldü; 6 hazır avatar üretildi. `pubspec.yaml` içine `flutter_launcher_icons:` ve `flutter_native_splash:` blokları yazıldı (üretim Aşama 4'te çalıştırılacak).
- Oluşturulan / değişen dosyalar:
  - [pubspec.yaml](pubspec.yaml), [l10n.yaml](l10n.yaml), [lib/main.dart](lib/main.dart), [lib/app.dart](lib/app.dart)
  - [app_colors.dart](lib/core/constants/app_colors.dart), [app_theme.dart](lib/core/theme/app_theme.dart), [local_storage_service.dart](lib/core/storage/local_storage_service.dart), [app_scope.dart](lib/core/di/app_scope.dart), [app_dependencies.dart](lib/core/di/app_dependencies.dart)
  - [seed_data.dart](lib/core/data/seed_data.dart), [validators.dart](lib/core/utils/validators.dart), [phone_input_formatter.dart](lib/core/utils/phone_input_formatter.dart)
  - [library_controller.dart](lib/core/controllers/library_controller.dart), [auth_controller.dart](lib/core/controllers/auth_controller.dart), [settings_controller.dart](lib/core/controllers/settings_controller.dart)
  - [app_icon.svg](assets/icon/app_icon.svg), [app_icon.png](assets/icon/app_icon.png), [app_icon_foreground.png](assets/icon/app_icon_foreground.png), [app_icon_monochrome.png](assets/icon/app_icon_monochrome.png), [splash_logo.png](assets/icon/splash_logo.png), [assets/avatars/](assets/avatars/)
  - [app_tr.arb](lib/l10n/app_tr.arb), [app_en.arb](lib/l10n/app_en.arb)
  - Testler: [validators_test.dart](test/core/validators_test.dart), [phone_input_formatter_test.dart](test/core/phone_input_formatter_test.dart), [models_test.dart](test/core/models_test.dart), [seed_data_test.dart](test/core/seed_data_test.dart), [library_storage_test.dart](test/core/library_storage_test.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 52 test geçti.
- Alınan kararlar ve nedenleri:
  - **Paylaşılan controller'lar `lib/core/controllers/` altında.** PROJECT.md 7'deki ağaçta bu klasör yok; ancak `AppScope` `core/di/` içinde olduğundan ve feature'lar birbirini import edemediğinden paylaşılan controller'ların `core/` altında olması gerekiyordu.
  - **Validator'lar saf ve metinsiz** (`ValidationError` enum'u döner); metne çevirme `validation_extensions.dart` ile ARB'den yapılır. Böylece validator'lar birim testlenebilir ve 8. bölümdeki "metin koda gömülmez" kuralı korunur.
  - **Telefon `0 (5XX) XXX XX XX` maskeli saklanmaz:** kullanıcı modelinde yalnızca rakamlar (`05321234567`) saklanır, gösterimde maske uygulanır.
  - **Şifre özeti** salt olmadan SHA-256'dır (PROJECT.md'nin istediği yöntem); yerel, tek kullanıcılı bir uygulama olduğu için salt eklenmedi.
  - **Tek yerel kullanıcı:** `kitalog.user` tek kullanıcı tutar; yeni kayıt mevcut kullanıcının yerine geçer, kitap verisi korunur.
  - **PROJECT.md 6.2 kutuları:** dosyada başlangıçta hepsi `[x]` işaretliydi; gerçek durumu yansıtması için `[ ]`'a çevrildi, tamamlandıkça işaretlenecek.
  - **ISBN düzeltmesi:** "Memleketimden İnsan Manzaraları" için Open Library'nin döndürdüğü `9789750803779` ISBN-13 sağlama toplamından geçmedi; geçerli karşılığı `9789750803772` kapak ve kayıt 200 yanıtıyla doğrulanıp kullanıldı (544 sayfa).
  - **Seed kitap seçimi:** Open Library'de başka dilde/kılavuz baskısına çıkan başlıklar (ör. Sapiens, 1984, Little Prince İngilizce) elendi; baskı başlığı ve sayfa sayısı eşleşen, kapağı 200 dönen baskılar seçildi. Orwell için `Animal Farm`, Yaşar Kemal için `Memed, My Hawk`, Orhan Pamuk için `Masumiyet Müzesi` ve `Snow`, Harari için `Homo Deus` ve `21 Lessons` kullanıldı.
  - `private named parameters` (`required this._repository`) kullanıldı; Dart 3.13 destekliyor ve `prefer_initializing_formals` lint'ini karşılıyor.
- Açık konular / sonraki adım:
  - Alıntı metinleri yayımlanmış eserlerden birebirdir; **sayfa numaraları yaygın baskılara göre verilmiştir ve seçilen ISBN baskısında doğrulanamadı** (baskıya göre kayabilir).
  - Sonraki adım: Aşama 2.1 – Splash + Kayıt/Giriş + Oturum yönlendirmesi.

## [2026-10-21] Aşama 2.1 – Splash + Kayıt/Giriş + Oturum Yönlendirmesi

- Yapılanlar:
  - Sayfa 0 (Splash): `SplashController` seed'i ve oturumu yükler, hedef rotayı belirler; yükleme hatasında "Tekrar dene" gösterilir. Yerel açılış ekranıyla aynı zemin (`#14161B`) ve logo kullanılır.
  - Sayfa 1 (Kayıt & Giriş): e-posta / telefon (maskeli) / şifre / şifre tekrar; `AutovalidateMode.onUserInteraction`; hata metinleri ARB'den; klavye türleri ve `autofillHints` PROJECT.md 6.4 tablosuna göre.
  - Ortak form alanları `core/widgets/` altında (`EmailFormField`, `PhoneFormField`, `PasswordFormField`) – Ayarlar ekranı da aynı alanları ve aynı `Validators`'ı kullanacak.
  - Ana kabuk: `NavigationBar` (3 sekme) + sağ üstte Ayarlar butonu; sekme sayfaları `AppRoutes` üzerinden verilir (şimdilik boş, sonraki adımlarda doldurulacak).
  - `AppRoutes.onGenerateRoute` bağlandı.
- Oluşturulan / değişen dosyalar:
  - [splash_view.dart](lib/features/splash/views/splash_view.dart), [splash_controller.dart](lib/features/splash/controllers/splash_controller.dart)
  - [register_view.dart](lib/features/auth/views/register_view.dart), [login_view.dart](lib/features/auth/views/login_view.dart), [register_controller.dart](lib/features/auth/controllers/register_controller.dart), [login_controller.dart](lib/features/auth/controllers/login_controller.dart), [register_form_widget.dart](lib/features/auth/widgets/register_form_widget.dart), [login_form_widget.dart](lib/features/auth/widgets/login_form_widget.dart)
  - [home_shell_view.dart](lib/features/home_shell/views/home_shell_view.dart), [home_shell_controller.dart](lib/features/home_shell/controllers/home_shell_controller.dart)
  - [email_form_field.dart](lib/core/widgets/email_form_field.dart), [phone_form_field.dart](lib/core/widgets/phone_form_field.dart), [password_form_field.dart](lib/core/widgets/password_form_field.dart), [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [auth_controller_test.dart](test/features/auth/auth_controller_test.dart), [register_form_test.dart](test/features/auth/register_form_test.dart), [splash_controller_test.dart](test/features/splash/splash_controller_test.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 63 test geçti.
- Alınan kararlar ve nedenleri:
  - **Splash'ın oturum yoksa hedefi Kayıt ekranıdır** (PROJECT.md 6.2/6.4); çıkış yapınca ise Giriş ekranına dönülür (6.4). Kayıt ekranında "Giriş yap" bağlantısı vardır.
  - **Ana kabuk sekmeleri rota katmanından verilir:** PROJECT.md 7 "bir feature başka bir feature'ın views/widgets'ını import etmez" dediği için `HomeShellView` sayfaları parametre olarak alır, bağlantı `core/routing/app_routes.dart`'ta yapılır.
  - Form widget'ları `TextEditingController` sahibi `StatefulWidget`'tır (8.1 izin verir); iş mantığı controller'dadır. Hata bandı giriş formunun dışındadır ve form `ValueKey` taşır, böylece hata görününce yazılan metin kaybolmaz.
- Açık konular / sonraki adım: Aşama 2.2 – Kitaplığım raf görünümü.

## [2026-10-21] Aşama 2.2 – Kitaplığım (Raf Görünümü) + Seed Data

- Yapılanlar:
  - Sayfa 2: kapakların grid/raf düzeninde listelenmesi (`GridView.builder`), başlık/yazar araması (Türkçe harf duyarsız), okuma durumu ve tür çipleriyle filtre, ödünçteki kitaplarda "Ödünçte" rozeti, boş / sonuçsuz durum mesajları, "Kitap Ekle" FAB'ı.
  - Seed verisi Aşama 1'de hazırlanmıştı; Splash ilk açılışta `kitalog.seeded` false iken bir kez yükler (36 kitap, 23 alıntı, 4 not, 4 ödünç, 24 kitaplık hedef).
  - Arama için `foldForSearch` (İ/I/ı, ç/ğ/ö/ş/ü sadeleştirme).
- Oluşturulan / değişen dosyalar:
  - [library_view.dart](lib/features/library/views/library_view.dart), [library_shelf_controller.dart](lib/features/library/controllers/library_shelf_controller.dart), [library_shelf_model.dart](lib/features/library/models/library_shelf_model.dart)
  - [book_shelf_grid_widget.dart](lib/features/library/widgets/book_shelf_grid_widget.dart), [book_shelf_item_widget.dart](lib/features/library/widgets/book_shelf_item_widget.dart), [library_filter_bar_widget.dart](lib/features/library/widgets/library_filter_bar_widget.dart), [loan_badge_widget.dart](lib/features/library/widgets/loan_badge_widget.dart), [library_empty_widget.dart](lib/features/library/widgets/library_empty_widget.dart)
  - [search_utils.dart](lib/core/utils/search_utils.dart), [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [library_shelf_controller_test.dart](test/features/library/library_shelf_controller_test.dart), [library_view_test.dart](test/features/library/library_view_test.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 70 test geçti.
- Alınan kararlar ve nedenleri:
  - **Raf controller'ı kitap listesini kopyalamaz;** paylaşılan `LibraryController.books` dinlenir, yalnızca filtre durumu ve türetilmiş liste tutulur (state_flow.md "tek doğruluk kaynağı"). `dispose`'ta `removeListener` çağrılır.
  - **İki filtre satırı** (durum + tür) ayrı çip satırları olarak verildi; PROJECT.md "Tür Etiketine ve Okuma Durumuna Göre Filtre" ifadesini karşılar.
  - Kapak yüklenemezse yer tutucu başlığı yazar; bu yüzden testlerde başlık metni birden çok kez bulunabilir.
- Açık konular / sonraki adım: Aşama 2.3 – Kitap Detay & Alıntı (rota şimdilik boş sayfa).

## [2026-10-21] Aşama 2.3 – Kitap Detay & Alıntı

- Yapılanlar:
  - Sayfa 5: kapak ve künye (tür etiketi, ISBN, sayfa sayısı, sahiplik), sayfa sayacı + ilerleme çubuğu (±1, ±10 ve doğrudan sayfa girişi), durum değiştirme (SegmentedButton), puan (1-5) ve şahsi inceleme, alıntılar (sayfa no, favori işaretleme – favoriler üstte, silme), notlar, ödünç bilgisi (kime, ne zaman, iade tarihi, gecikme uyarısı, iade alma), kitap silme (onay diyaloğuyla; bağlı alıntı/notlar da silinir).
  - Son sayfaya ulaşınca SnackBar ile "Bitti olarak işaretle" önerisi (PROJECT.md 6.3: "pageCount'a ulaşınca durum finished önerilir").
  - Rota: `AppRoutes.bookDetail` (argüman: kitap id'si).
- Oluşturulan / değişen dosyalar:
  - [book_detail_view.dart](lib/features/book_detail/views/book_detail_view.dart), [book_detail_controller.dart](lib/features/book_detail/controllers/book_detail_controller.dart), [book_detail_model.dart](lib/features/book_detail/models/book_detail_model.dart), [book_detail_actions.dart](lib/features/book_detail/models/book_detail_actions.dart)
  - Widget'lar: [book_detail_content_widget.dart](lib/features/book_detail/widgets/book_detail_content_widget.dart), [book_header_widget.dart](lib/features/book_detail/widgets/book_header_widget.dart), [page_counter_widget.dart](lib/features/book_detail/widgets/page_counter_widget.dart), [status_selector_widget.dart](lib/features/book_detail/widgets/status_selector_widget.dart), [rating_review_widget.dart](lib/features/book_detail/widgets/rating_review_widget.dart), [quotes_section_widget.dart](lib/features/book_detail/widgets/quotes_section_widget.dart), [notes_section_widget.dart](lib/features/book_detail/widgets/notes_section_widget.dart), [loan_section_widget.dart](lib/features/book_detail/widgets/loan_section_widget.dart) ve diyaloglar ([quote_dialog.dart](lib/features/book_detail/widgets/quote_dialog.dart), [loan_dialog.dart](lib/features/book_detail/widgets/loan_dialog.dart), [page_input_dialog.dart](lib/features/book_detail/widgets/page_input_dialog.dart), [text_entry_dialog.dart](lib/features/book_detail/widgets/text_entry_dialog.dart))
  - [context_extensions.dart](lib/core/extensions/context_extensions.dart) (`formatDate`), [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [book_detail_controller_test.dart](test/features/book_detail/book_detail_controller_test.dart), [book_detail_view_test.dart](test/features/book_detail/book_detail_view_test.dart), [pump_app.dart](test/helpers/pump_app.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 83 test geçti.
- Alınan kararlar ve nedenleri:
  - **Widget'lar controller'a bağımlı değildir:** controller'ın eylemleri `BookDetailActions` nesnesiyle verilir (8.1 ve state_flow.md "widget katmanı"). Bölümler ayrı widget sınıflarıdır; hiçbir `build` 40 satırı aşmaz.
  - **Veri tek kaynaktan:** detay controller'ı kitabı/alıntıyı/notu kopyalamaz; `LibraryController` notifier'larını dinleyip kitaba göre süzer ve `dispose`'ta dinleyicileri kaldırır.
  - **Alıntı/not düzenleme eklenmedi;** PROJECT.md yalnızca ekleme, favorileme ve silmeyi istiyor (kapsam dışına çıkılmadı).
  - Durum "Bitti"ye alınınca sayfa sayısı otomatik `pageCount` olur ve bitiş tarihi yazılır; "Okunacak"a dönülünce başlangıç/bitiş tarihleri temizlenir.
- Açık konular / sonraki adım: Aşama 2.4 – Okuma Durumu sekmeleri.

## [2026-10-21] Aşama 2.4 – Okuma Durumu

- Yapılanlar:
  - Sayfa 4: Okunuyor / Okunacak / Bitti sekmeleri (sekme başlığında kitap sayısı). Okunuyor kartlarında ilerleme yüzdesi, ilerleme çubuğu ve hızlı sayfa sayacı (−/+); Okunacak kartlarında "Okumaya Başla"; Bitti kartlarında puan ve bitiş tarihi. Karta dokununca Kitap Detay açılır. Boş sekmeler için mesajlar.
  - Hızlı sayacla son sayfaya ulaşılırsa "Bitti olarak işaretle" önerisi gösterilir.
- Oluşturulan / değişen dosyalar:
  - [reading_status_view.dart](lib/features/reading_status/views/reading_status_view.dart), [reading_status_controller.dart](lib/features/reading_status/controllers/reading_status_controller.dart), [reading_status_model.dart](lib/features/reading_status/models/reading_status_model.dart)
  - [reading_book_card_widget.dart](lib/features/reading_status/widgets/reading_book_card_widget.dart), [simple_book_card_widget.dart](lib/features/reading_status/widgets/simple_book_card_widget.dart), [quick_page_counter_widget.dart](lib/features/reading_status/widgets/quick_page_counter_widget.dart), [status_book_list_widget.dart](lib/features/reading_status/widgets/status_book_list_widget.dart), [status_empty_widget.dart](lib/features/reading_status/widgets/status_empty_widget.dart)
  - [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [reading_status_controller_test.dart](test/features/reading_status/reading_status_controller_test.dart), [reading_status_view_test.dart](test/features/reading_status/reading_status_view_test.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 90 test geçti.
- Alınan kararlar ve nedenleri:
  - **Sekme sırası** PROJECT.md'deki gibi Okunuyor → Okunacak → Bitti.
  - **Sıralama:** Okunuyor ilerlemeye göre azalan, Bitti bitiş tarihine göre azalan (en yeni üstte); Okunacak kayıt sırasıyla.
  - `TabController`, `DefaultTabController` ile Flutter tarafından yönetilir; sekme seçimi için `setState` kullanılmadı.
  - Boş durum widget'ı `_buildXxx` yardımcı metot yerine ayrı sınıf (`StatusEmptyWidget`) olarak yazıldı (8.2).
- Açık konular / sonraki adım: Aşama 2.5 – Yeni Kitap Ekle (Open Library + manuel form).

## [2026-10-21] Aşama 2.5 – Yeni Kitap Ekle (Open Library + Manuel)

- Yapılanlar:
  - Sayfa 3: "ISBN / Arama" ve "Manuel" modları. ISBN (10/13 hane, sağlama toplamı doğrulanır) veya başlık/yazar yazılarak Open Library'de aranır; sonuçlarda kapak, yazar, sayfa sayısı ve tahmini tür etiketi görünür. Bir sonuca dokununca manuel form (başlık, yazar, sayfa sayısı, tür, durum, ISBN, kapak URL, "bende var") ön doldurulur; tür/durum onaylanıp kitaplığa eklenir.
  - Sonuç bulunamazsa, ağ yoksa veya API hata verirse ilgili mesaj + "Tekrar dene" + "Manuel Ekle" seçenekleri gösterilir.
  - Aynı ISBN ikinci kez eklenemez (uyarı çıkar).
  - Gerçek API yanıt biçimi `curl` ile doğrulandı (`search.json?q=isbn:...&fields=...`).
  - `BookSearchRepository` (`http` ile, 10 sn zaman aşımı) `AppScope`/`AppDependencies` üzerinden sağlanır; testte `http.Client` enjekte edilebilir.
  - Kod kalite taraması: tüm `build` metotları 40 satır sınırının altına indirildi (Aşama 2.1-2.4 dosyaları dahil, ör. ortak `BookCardLayoutWidget`, `AuthFormActionsWidget`).
- Oluşturulan / değişen dosyalar:
  - [add_book_view.dart](lib/features/add_book/views/add_book_view.dart), [add_book_controller.dart](lib/features/add_book/controllers/add_book_controller.dart), [add_book_model.dart](lib/features/add_book/models/add_book_model.dart)
  - [add_book_body_widget.dart](lib/features/add_book/widgets/add_book_body_widget.dart), [manual_book_form_widget.dart](lib/features/add_book/widgets/manual_book_form_widget.dart), [book_identity_fields_widget.dart](lib/features/add_book/widgets/book_identity_fields_widget.dart), [book_classification_fields_widget.dart](lib/features/add_book/widgets/book_classification_fields_widget.dart), [book_optional_fields_widget.dart](lib/features/add_book/widgets/book_optional_fields_widget.dart), [search_section_widget.dart](lib/features/add_book/widgets/search_section_widget.dart), [search_result_tile_widget.dart](lib/features/add_book/widgets/search_result_tile_widget.dart), [search_message_widget.dart](lib/features/add_book/widgets/search_message_widget.dart), [book_search_bar_widget.dart](lib/features/add_book/widgets/book_search_bar_widget.dart)
  - [book_search_repository.dart](lib/core/repositories/book_search_repository.dart), [book_search_result.dart](lib/core/models/book_search_result.dart), [isbn_utils.dart](lib/core/utils/isbn_utils.dart), [validators.dart](lib/core/utils/validators.dart), [app_dependencies.dart](lib/core/di/app_dependencies.dart), [app_scope.dart](lib/core/di/app_scope.dart)
  - Testler: [add_book_controller_test.dart](test/features/add_book/add_book_controller_test.dart), [add_book_view_test.dart](test/features/add_book/add_book_view_test.dart), [book_search_repository_test.dart](test/core/book_search_repository_test.dart), [isbn_utils_test.dart](test/core/isbn_utils_test.dart), [fake_open_library.dart](test/helpers/fake_open_library.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 109 test geçti.
- Alınan kararlar ve nedenleri:
  - **ISBN araması iki adımlıdır:** önce `search.json?q=isbn:<ISBN>` (yazar ve sayfa sayısı için), sonuç yoksa `isbn/<ISBN>.json` (PROJECT.md 6.1'deki iki endpoint de kullanılır). `isbn/<ISBN>.json` yazar adını doğrudan vermediği için yalnızca yedek olarak kullanılır.
  - **Arama sonucu doğrudan eklenmez, forma taşınır:** Open Library tür bilgisi vermediğinden tür konu etiketlerinden tahmin edilir (`guessGenre`); kullanıcı tür ve durumu onaylar.
  - **Kapak:** sonuçta `cover_i` varsa `covers/b/id/<id>-L.jpg`, yoksa ISBN'den `covers/b/isbn/<ISBN>-L.jpg` kullanılır (ikisi de onaylı Open Library Covers servisi).
  - **Hata mesajları state'e metin değil `AddBookError` enum'u olarak yazılır** (state_flow.md 5); view ARB'den çevirir. Ağ hataları (`TimeoutException`, `ClientException`, soket hataları) tek bir `network` hatasına indirgenir; `dart:io` import edilmediği için kod web'de de derlenir.
  - `Column(spacing: ...)` kullanıldı (Flutter ≥ 3.27) – ayırıcı `SizedBox` satırları azaldığı için build metotları kısa kalır.
- Açık konular / sonraki adım: Aşama 2.6 – Yıllık Hedef Paneli.

## [2026-10-21] Aşama 2.6 – Yıllık Okuma Hedefi Paneli

- Yapılanlar:
  - Sayfa 6: yıllık hedef kitap sayısı (−/+ ile 1-365 arası, kalıcı), Biten / Hedef ilerleme çubuğu ve "kalan" mesajı (hedefe ulaşılınca tebrik), toplam okunan sayfa, aylık biten kitap dağılımı (paket kullanmadan çizilen çubuk grafik, erişilebilirlik etiketli) ve türlere göre dağılım (tür renkleriyle).
  - Tüm değerler `BookModel.finishedAt` yılından hesaplanır; kitap durumu değişince panel otomatik güncellenir.
- Oluşturulan / değişen dosyalar:
  - [reading_goal_view.dart](lib/features/reading_goal/views/reading_goal_view.dart), [reading_goal_controller.dart](lib/features/reading_goal/controllers/reading_goal_controller.dart), [reading_goal_state.dart](lib/features/reading_goal/models/reading_goal_state.dart)
  - [goal_progress_card_widget.dart](lib/features/reading_goal/widgets/goal_progress_card_widget.dart), [goal_target_stepper_widget.dart](lib/features/reading_goal/widgets/goal_target_stepper_widget.dart), [goal_stat_card_widget.dart](lib/features/reading_goal/widgets/goal_stat_card_widget.dart), [monthly_chart_widget.dart](lib/features/reading_goal/widgets/monthly_chart_widget.dart), [genre_breakdown_widget.dart](lib/features/reading_goal/widgets/genre_breakdown_widget.dart)
  - [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [reading_goal_controller_test.dart](test/features/reading_goal/reading_goal_controller_test.dart), [reading_goal_view_test.dart](test/features/reading_goal/reading_goal_view_test.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 117 test geçti.
- Alınan kararlar ve nedenleri:
  - **Feature state sınıfı `ReadingGoalState`** (örnek dosyadaki `ReadingGoalModel` adı `core/models/` altındaki paylaşılan `ReadingGoalModel` ile çakışacağı için; state_flow.md de `ReadingGoalState` adını kullanır).
  - **Toplam okunan sayfa** = bu yıl biten kitapların sayfa sayısı + şu an okunmakta olan kitapların mevcut sayfası. PROJECT.md bu hesabı tanımlamıyor; en yakın doğal yorum buydu.
  - **Aylık ve tür dağılımı yalnızca bu yıl biten kitapları sayar** (hedefle tutarlılık için).
  - **Grafik için paket eklenmedi** (onaylı liste dışı paket yasağı); çubuklar `FractionallySizedBox` ile çizildi, ay adları `intl` `DateFormat.MMM` ile dile göre yazılır.
  - Yalnızca içinde bulunulan yıl gösterilir; geçmiş yıllara gezinme PROJECT.md'de istenmediği için eklenmedi.
- Açık konular / sonraki adım: Aşama 2.7 – Ayarlar.

## [2026-10-21] Aşama 2.7 – Ayarlar

- Yapılanlar:
  - Sayfa 7: profil resmi ve kullanıcı özeti (e-posta, maskeli telefon, üyelik tarihi); profil resmi seçimi (6 hazır avatar, galeriden yükleme, mobilde kameradan çekme, kaldırma); tema (Karanlık varsayılan / Aydınlık) ve dil (Türkçe varsayılan / English) seçimi – anında uygulanır ve kalıcıdır; e-posta, telefon ve şifre güncelleme (Kayıt ekranıyla AYNI alanlar ve validator'lar, şifrede mevcut şifre doğrulanır, e-posta değişimi giriş bilgisini de günceller); onaylı "Çıkış Yap" (oturum kapanır, veriler silinmez, Giriş ekranına dönülür).
  - Ana kabuktaki sağ üst Ayarlar simgesi artık gerçek ekrana gidiyor.
  - `UserAvatar` ortak widget'ı (`core/widgets/`), `AppAssets` sabitleri.
- Oluşturulan / değişen dosyalar:
  - [settings_view.dart](lib/features/settings/views/settings_view.dart), [settings_screen_controller.dart](lib/features/settings/controllers/settings_screen_controller.dart), [avatar_picker.dart](lib/features/settings/controllers/avatar_picker.dart), [settings_screen_model.dart](lib/features/settings/models/settings_screen_model.dart)
  - [settings_body_widget.dart](lib/features/settings/widgets/settings_body_widget.dart), [profile_summary_widget.dart](lib/features/settings/widgets/profile_summary_widget.dart), [appearance_section_widget.dart](lib/features/settings/widgets/appearance_section_widget.dart), [account_section_widget.dart](lib/features/settings/widgets/account_section_widget.dart), [email_update_form_widget.dart](lib/features/settings/widgets/email_update_form_widget.dart), [phone_update_form_widget.dart](lib/features/settings/widgets/phone_update_form_widget.dart), [password_update_form_widget.dart](lib/features/settings/widgets/password_update_form_widget.dart), [avatar_options_sheet.dart](lib/features/settings/widgets/avatar_options_sheet.dart)
  - [user_avatar.dart](lib/core/widgets/user_avatar.dart), [app_assets.dart](lib/core/constants/app_assets.dart), [app_routes.dart](lib/core/routing/app_routes.dart)
  - Testler: [settings_screen_controller_test.dart](test/features/settings/settings_screen_controller_test.dart), [settings_view_test.dart](test/features/settings/settings_view_test.dart), [fake_avatar_picker.dart](test/helpers/fake_avatar_picker.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 129 test geçti.
- Alınan kararlar ve nedenleri:
  - **Yüklenen profil resmi dosya yolu yerine küçültülmüş (512 px) baytların base64'ü olarak `UserModel.avatarValue`'da saklanır.** PROJECT.md "uygulama dizinine kopyalanır ve yolu avatarValue'ya yazılır" der; ancak uygulama dizinini bulmak için `path_provider` gerekir ve bu paket onaylı listede yok. Ayrıca web hedefinde dosya yolu kavramı yoktur ve `image_picker`'ın döndürdüğü geçici yol (cache/tmp) sistem tarafından silinebilir. Base64 saklama onaylı paketlerle (`image_picker` + `shared_preferences`) çalışır, tüm platformlarda kalıcıdır. Ödün: kullanıcı JSON'ı ~30-60 KB büyür. **Karar sana kalıyor:** `path_provider` onaylanırsa yalnızca `AvatarPicker` implementasyonu ve `UserAvatar` değişir.
  - Kamera seçeneği yalnızca Android/iOS'ta gösterilir (`image_picker` masaüstünde/webde kamerayı desteklemez).
  - Tema seçimi iki seçenekli (Karanlık / Aydınlık); `ThemeMode.system` PROJECT.md'de olmadığı için sunulmadı.
  - Ayarlar sayfasındaki ilk kayıtlar için e-posta benzersizliği kontrolü yoktur: uygulama tek yerel kullanıcılıdır.
  - Yan etki mesajları (SnackBar) `builder` içinde değil, controller state'inin dinleyicisinde (`SettingsMessage` anahtarı) gösterilir.
- Açık konular / sonraki adım: Aşama 3 – Test & İyileştirme. Ayrıca iOS için `Info.plist` izin metinleri (galeri/kamera) Aşama 4'te eklenecek.

## [2026-10-21] Aşama 3 – Test & İyileştirme

- Yapılanlar:
  - **Birim testleri:** validator'lar (e-posta, telefon, şifre, şifre tekrar, sayfa sayısı, URL, ISBN – tablo bazlı), telefon maskesi, ISBN yardımcıları, tüm modellerin `fromJson`/`toJson` gidiş-dönüşü ve `copyWith` sınırları, seed verisi (ISBN sağlama toplamı, tür/durum dağılımı, tarih mantığı), `LocalStorageService` (bozuk JSON dahil), Open Library istemcisi (sahte HTTP ile ayrıştırma, ağ/sunucu hatası, tür tahmini) ve tüm controller'lar (Library, Auth, Splash, Register/Login, Raf, Detay, Okuma Durumu, Ekle, Hedef, Ayarlar).
  - **Widget testleri:** Kayıt formu (doğrulama, maske, başarılı kayıt → ana sayfa, oturumlu açılış), Kitap Detay (sayaç, bitirme önerisi, alıntı/favori/ödünç akışı, silme, bulunamadı), Kitaplığım (arama, filtre, boş durum), Okuma Durumu, Yeni Kitap Ekle (arama, manuel form, internet yok, geçersiz ISBN), Hedef Paneli, Ayarlar (tema/dil anında, hesap güncelleme, avatar, çıkış), `BookCoverImage` yer tutucusu.
  - **Hata/boş durumlar:** internet yok, API hatası, sonuç yok, bozuk kayıtlı veri, yüklenemeyen kapak, boş kitaplık/sekme/tür dağılımı.
  - **Farklı ekran boyutları ve erişilebilirlik:** 8 ekran × 4 boyut (320×568, 390×844, 820×1180, 1280×800) × 2 yazı ölçeği (1.0 / 1.6) taşma testleri; Android/iOS dokunma hedefi (48/44 dp), etiketli dokunma hedefi ve metin kontrastı kılavuz testleri.
  - **Bulunan ve düzeltilen sorunlar:** hedef adımlayıcı, ilerleme çubuğu alt yazısı ve hızlı sayaç dar ekranda taşıyordu; `EmptyStateView` küçük ekranda dikey taşıyordu (kaydırılabilir yapıldı); filtre çiplerinin dokunma hedefi 40 dp idi (56 dp satır + `MaterialTapTargetSize.padded`).
  - **Kod standartları taraması:** `Color(0x…)` yalnızca `app_colors.dart`'ta; widget içinde `fontSize` yok; sabit kullanıcı metni yok (yalnızca sayı gösteren `Text('$n')`); `SharedPreferences` yalnızca `LocalStorageService`'te; `setState` yalnızca yerel UI durumunda (şifre göster/gizle, diyalog tarihi, form seçimleri); tüm `build` metotları ≤ 40 satır.
- Oluşturulan / değişen dosyalar:
  - [responsive_test.dart](test/accessibility/responsive_test.dart), [guidelines_test.dart](test/accessibility/guidelines_test.dart), [book_cover_image_test.dart](test/core/book_cover_image_test.dart), [local_storage_service_test.dart](test/core/local_storage_service_test.dart), [library_empty_test.dart](test/features/library/library_empty_test.dart), [validators_test.dart](test/core/validators_test.dart)
  - [empty_state_view.dart](lib/core/widgets/empty_state_view.dart), [reading_progress_bar.dart](lib/core/widgets/reading_progress_bar.dart), [goal_target_stepper_widget.dart](lib/features/reading_goal/widgets/goal_target_stepper_widget.dart), [reading_book_card_widget.dart](lib/features/reading_status/widgets/reading_book_card_widget.dart), [library_filter_bar_widget.dart](lib/features/library/widgets/library_filter_bar_widget.dart), [app_theme.dart](lib/core/theme/app_theme.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 227 test geçti.
- Alınan kararlar ve nedenleri:
  - **Taşma testleri `flutter_test`'in Ahem yazı tipiyle çalışır** (her harf 1 em genişliğinde, gerçek Roboto'dan yaklaşık %80 daha geniş); bu yüzden testi geçen bir ekran gerçek cihazda ~3× yazı ölçeğine kadar taşmaz. Daha sıkı olduğu için bilinçli olarak korundu.
  - Taşma çözümleri yerleşimi bozmadan yapıldı: uzun metinler `Flexible` + üç nokta, sayaç `FittedBox(scaleDown)`, boş durum kaydırılabilir.
  - Gerçek ağa çıkan test yazılmadı; Open Library istemcisi `http` paketinin `MockClient`'ı ile test edilir (ağ erişimine ve API'nin anlık durumuna bağımlı olmamak için). Gerçek API yanıt biçimi Aşama 2.5'te `curl` ile elle doğrulandı.
- Açık konular / sonraki adım: Aşama 4 – Final teslim (ikon ve açılış ekranının platformlara uygulanması, uygulama adı, iOS izin metinleri, README).

## [2026-10-21] Aşama 4 – Final Teslim

- Yapılanlar:
  - `dart run flutter_launcher_icons`: Android (adaptive + monochrome, arka plan `#14161B`), iOS (alfa kanalsız 1024 px doğrulandı), Web (`#14161B` / `#F2A93B`), Windows ve macOS ikonları üretildi.
  - `dart run flutter_native_splash:create`: `#14161B` zemin + logo; Android (Android 12+ `values-v31` / `values-night-v31` dahil), iOS ve Web için üretildi.
  - Uygulama adı "Kitalog": Android `android:label`, iOS `CFBundleDisplayName`/`CFBundleName`, Web `manifest.json` + `index.html`, macOS `PRODUCT_NAME` (+ Xcode proje ve şema referansları), Windows pencere başlığı/`Runner.rc`, Linux pencere başlığı.
  - iOS `Info.plist`'e galeri ve kamera izin metinleri eklendi (profil resmi için).
  - Son kontroller: `flutter build apk --debug` ✔ ve `flutter build ios --simulator` ✔; uygulama iOS simülatöründe (iPhone 18 Pro) çalıştırılıp 9 ekran görüntüsü alındı. Görüntülerde bulunan bir sorun düzeltildi: kitap detayında durum seçicisinin etiketleri ("Okunacak", "Okunuyor") kelime ortasından bölünüyordu → segment simgeleri kaldırıldı.
  - README ve ekran görüntüleri eklendi.
  - Ana kabuğa `initialIndex` parametresi eklendi (test ve ekran görüntüsü için; varsayılan davranış değişmedi) ve [home_shell_test.dart](test/features/home_shell/home_shell_test.dart) yazıldı.
- Oluşturulan / değişen dosyalar:
  - [README.md](README.md), [docs/screenshots/](docs/screenshots/), [pubspec.yaml](pubspec.yaml)
  - [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml), [Info.plist](ios/Runner/Info.plist), [manifest.json](web/manifest.json), [index.html](web/index.html), [AppInfo.xcconfig](macos/Runner/Configs/AppInfo.xcconfig), [main.cpp](windows/runner/main.cpp), [my_application.cc](linux/runner/my_application.cc)
  - [status_selector_widget.dart](lib/features/book_detail/widgets/status_selector_widget.dart), [home_shell_view.dart](lib/features/home_shell/views/home_shell_view.dart)
- Doğrulama: `flutter pub get` ✔, `flutter gen-l10n` ✔, `flutter analyze` → 0 uyarı / 0 hata, `flutter test` → 230 test geçti; Android debug APK ve iOS simülatör derlemesi başarılı.
- Alınan kararlar ve nedenleri:
  - **Ekran görüntüleri için geçici bir giriş noktası kullanıldı ve silindi** (`tool/screenshot_main.dart`); üretim koduna ekran görüntüsü modu eklenmedi.
  - Simülatörde aynı paket adıyla kalmış eski bir kurulumun verisi ilk görüntülerde göründüğü için uygulama kaldırılıp görüntüler yeniden alındı.
  - macOS ürün adı değiştiği için Xcode proje (`TEST_HOST`, ürün referansı) ve şema dosyaları da `Kitalog.app` olacak şekilde güncellendi; macOS derlemesi çalıştırılıp doğrulanmadı.
- Açık konular / sonraki adım: aşağıdaki final özetine bakın.

---

## Final Özeti

**Tamamlananlar**
- PROJECT.md 6.6'daki 4 aşamanın tamamı; Aşama 2'deki 7 ekran belirtilen sırayla. PROJECT.md 6.2'deki 8 sayfa maddesi `[x]` işaretlendi. 6.7 bölümüne ve git'e dokunulmadı (commit atılmadı).
- 9 feature (`splash`, `auth`, `home_shell`, `library`, `add_book`, `reading_status`, `book_detail`, `reading_goal`, `settings`), 6 repository, 3 paylaşılan controller, ortak widget'lar, TR/EN ARB (218 anahtar), koyu/aydınlık tema.
- Yalnızca onaylı paketler kullanıldı (`cupertino_icons` kaldırıldı). Ağır `setState` yok; `build` metotları ≤ 40 satır; renk/metin/kullanıcı metni kodda gömülü değil.
- Özel ikon (SVG → PNG), 6 hazır avatar, yerel açılış ekranı, ad "Kitalog".
- Seed: 36 gerçek kitap (ISBN'leri Open Library'de ve ISBN-13 sağlama toplamıyla doğrulandı, kapakları 200 dönüyor), 23 alıntı, 4 not, 4 ödünç, 24 kitaplık hedef.

**Son sonuçlar**
- `flutter analyze`: 0 uyarı, 0 hata. `flutter test`: 230 test, hepsi geçti.
- Android debug APK ve iOS simülatör derlemesi başarılı; uygulama iOS simülatöründe çalıştırıldı.

**Ertelenen / yapılmayan işler**
- Gerçek cihazda (fiziksel Android/iOS), macOS/Windows/Linux masaüstünde ve web'de çalıştırma yapılmadı; yalnızca Android/iOS derlemesi ve iOS simülatörü denendi.
- Galeri/kamera ile profil resmi seçimi simülatörde elle denenmedi (birim ve widget testleri sahte seçiciyle yapıldı).
- Sunum (Aşama 4 "Sunum" maddesi) hazırlanmadı; PROJECT.md 6.7 senin için boş bırakıldı.
- PROJECT.md 6.4'teki iki `[]` kutusu dokunulmadan bırakıldı (yalnızca 6.2 işaretlenmesi istenmişti).

**Bana kalan kararlar**
1. **Profil resmi saklama:** Yüklenen resim dosya yolu yerine base64 olarak saklanıyor (`path_provider` onaylı listede yok; web ve kalıcılık için). `path_provider` onaylarsan dosya tabanlı saklamaya geçilir.
2. **Alıntı sayfa numaraları:** Alıntı metinleri yayımlanmış eserlerden birebir, ancak sayfa numaralarını seçilen ISBN baskısında doğrulayamadım; baskıya göre kayabilir. Kesin istiyorsan numaralar kaldırılabilir veya elle düzeltilebilir.
3. **Seed kapakları:** Bazı Open Library kapakları kitabın ön kapağı değil (örn. "Tutunamayanlar" için bir iç sayfa görseli); veri doğru ISBN'e ait olduğu için olduğu gibi bırakıldı.
4. **Şifre özeti** tuzsuz SHA-256'dır (PROJECT.md'nin istediği yöntem); gerçek bir sunucuya geçilirse sunucu taraflı güvenli hash gerekir.
5. Splash'ın oturum yokken Kayıt ekranına (çıkış sonrası Giriş ekranına) yönlendirmesi PROJECT.md'ye göre uygulandı; çıkış yapmış kullanıcıyı da önce Giriş'e götürmek istersen tek satırlık değişiklik.

Şimdi `flutter analyze` ile kontrol edebilirsin.
