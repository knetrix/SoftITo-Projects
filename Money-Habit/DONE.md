# Proje İlerleme Takibi (DONE.md)

| Aşama | Durum |
|---|---|
| Aşama 1: Kurulum & Temel Altyapı | Tamamlandı |
| Aşama 2: Kimlik Doğrulama & Oturum (`features/auth`) | Tamamlandı |
| Aşama 3: Ayarlar Modülü (`features/settings`) | Tamamlandı |
| Aşama 4: Harcamalar Modülü (`features/expenses`) | Tamamlandı |
| Aşama 5: Bütçe & İstatistik Modülü (`features/budget`) | Tamamlandı |
| Aşama 6: Finansal Hedeflerim Modülü (`features/goals`) | Tamamlandı |
| Aşama 7: 10 Günlük Challenge & Streak Modülü (`features/challenge`) | Tamamlandı |
| Aşama 8: Ana Kabuk & Ana Panel (`features/home`, `features/dashboard`) | Tamamlandı |
| Aşama 9: Uygulama İkonu, Açılış Ekranı (Splash) ve Platform Ayarları | Tamamlandı |
| Aşama 10: Uçtan Uca Test, Statik Analiz ve Final Doğrulama | Tamamlandı |

---

## [2026-10-23] Aşama 1 – Kurulum & Temel Altyapı

### Yapılanlar
- Flutter projesi oluşturuldu (`flutter create --org com.example --project-name money_habit_tracker .`).
- `pubspec.yaml` beyaz listedeki paketlerle (shared_preferences, crypto, image_picker, path_provider, intl, flutter_localizations, flutter_launcher_icons, flutter_native_splash) yapılandırıldı.
- `l10n.yaml` ve TR/EN ARB dosyaları (`lib/core/l10n/app_tr.arb`, `lib/core/l10n/app_en.arb`) oluşturuldu ve `flutter gen-l10n` çalıştırıldı.
- Sabitler oluşturuldu: `app_colors.dart` (Gece Finans Paleti: Deep Navy, Emerald, Gold & Light Tema & Kategori Renkleri), `app_sizes.dart`, `storage_keys.dart`.
- Servis ve araçlar kodlandı: `local_storage_service.dart`, `validators.dart` (E-posta, telefon ve şifre kuralları), `password_hasher.dart` (SHA-256 hash).
- Uzantılar kodlandı: `context_extensions.dart`, `money_extensions.dart` (kuruş dönüşüm ve formatlama), `date_extensions.dart`, `validation_l10n_extension.dart`.
- Material 3 tema altyapısı kuruldu: `app_theme.dart` (Koyu varsayılan, Aydınlık seçilebilir) ve `app_text_styles.dart`.
- Ortak bileşenler yazıldı: `app_primary_button.dart`, `app_text_field.dart`, `amount_text.dart`, `progress_bar_card.dart`, `empty_state_widget.dart`, `section_header.dart`, `settings_action_button.dart`.
- Rota ve temel uygulama iskeleti kuruldu: `app_router.dart`, `app.dart`, `main.dart`.
- Birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [pubspec.yaml](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/pubspec.yaml): Paket bağımlılıkları ve asset tanımlarını içerir.
- [l10n.yaml](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/l10n.yaml): Çoklu dil yapılandırma dosyasını tanımlar.
- [lib/core/l10n/app_tr.arb](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/l10n/app_tr.arb): Türkçe dil çeviri anahtarlarını barındırır.
- [lib/core/l10n/app_en.arb](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/l10n/app_en.arb): İngilizce dil çeviri anahtarlarını barındırır.
- [lib/core/constants/app_colors.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/constants/app_colors.dart): Koyu/aydınlık tema ve harcama kategori renklerini tanımlar.
- [lib/core/constants/app_sizes.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/constants/app_sizes.dart): Padding, spacing, radius ve bileşen boyut sabitlerini içerir.
- [lib/core/constants/storage_keys.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/constants/storage_keys.dart): SharedPreferences depolama anahtarlarını içerir.
- [lib/core/services/local_storage_service.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/services/local_storage_service.dart): Kalıcı yerel depolama yönetimini sağlar.
- [lib/core/utils/password_hasher.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/utils/password_hasher.dart): SHA-256 ile şifre özetleme ve doğrulama yapar.
- [lib/core/utils/validators.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/utils/validators.dart): E-posta, telefon ve şifre kurallarını doğrular.
- [lib/core/extensions/context_extensions.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/extensions/context_extensions.dart): Tema ve l10n context kısayollarını sunar.
- [lib/core/extensions/validation_l10n_extension.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/extensions/validation_l10n_extension.dart): Validasyon hatalarını l10n metinlerine dönüştürür.
- [lib/core/extensions/money_extensions.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/extensions/money_extensions.dart): Kuruş para ayrıştırma ve para birimi formatlama uzantılarını sunar.
- [lib/core/extensions/date_extensions.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/extensions/date_extensions.dart): Tarih biçimlendirme ve ay anahtarı (`yyyy-MM`) hesaplamalarını yapar.
- [lib/core/theme/app_text_styles.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/theme/app_text_styles.dart): Metin stili hiyerarşisini tanımlar.
- [lib/core/theme/app_theme.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/theme/app_theme.dart): Material 3 koyu ve aydınlık temalarını yapılandırır.
- [lib/core/widgets/app_primary_button.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/app_primary_button.dart): Dolgulu ve çerçeveli buton bileşenini sunar.
- [lib/core/widgets/app_text_field.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/app_text_field.dart): Validasyon ve klavye destekli ortak metin giriş alanıdır.
- [lib/core/widgets/amount_text.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/amount_text.dart): Kuruşu formatlı para metni olarak gösterir.
- [lib/core/widgets/progress_bar_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/progress_bar_card.dart): Hedef ve ilerleme gösterge kartı bileşenidir.
- [lib/core/widgets/empty_state_widget.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/empty_state_widget.dart): Veri olmadığında kullanıcıya gösterilen durum bileşenidir.
- [lib/core/widgets/section_header.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/section_header.dart): Başlık ve aksiyon butonu içeren bölüm başlığıdır.
- [lib/core/widgets/settings_action_button.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/settings_action_button.dart): AppBar sağ üstündeki ayarlar butonudur.
- [lib/core/router/app_router.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/router/app_router.dart): İsimli rotaları (`onGenerateRoute`) yönetir.
- [lib/app.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/app.dart): Tema, dil ve rota dinleyicilerini bağlayan ana uygulama bileşenidir.
- [lib/main.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/main.dart): Sadece depolama başlatma ve runApp çağrısı yapar.
- [test/core/utils/validators_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/core/utils/validators_test.dart): Validatör, hasher ve para format birim testleridir.
- [test/core/services/local_storage_service_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/core/services/local_storage_service_test.dart): Depolama servisinin JSON okuma/yazma birim testleridir.

**Silinen:**
- `test/widget_test.dart`: Varsayılan sayaç testi silindi.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 17 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- PROJECT.md doğrultusunda Material 3 Gece Finans paleti (Deep Navy, Emerald, Gold) temel koyu tema olarak ayarlandı.
- Flutter 3.47.7 gereksinimine uygun olarak `CardThemeData` ve `.withValues(alpha: ...)` API'leri kullanıldı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 2 – Kimlik Doğrulama & Oturum (`features/auth`)

### Yapılanlar
- `UserModel` ve `AvatarModel` modelleri immutable olarak oluşturuldu.
- `AuthController` iş mantığı kodlandı: `register`, `login`, `quickLogin` (hızlı test kullanıcısı) ve `logout`.
- Form validasyonları ve şifre gizleme/gösterme bileşeni `PasswordField` kodlandı.
- Ortak başlık ve logo bileşeni `AuthHeader` yazıldı.
- `RegisterView` ve `LoginView` ekranları Material 3 tasarım diline uygun olarak kodlandı, 40 satır sınırı için form alanları `RegisterFormFields` ve `LoginFormFields` bileşenlerine bölündü.
- Hızlı giriş (test kullanıcısı) desteği eklendi.
- `AuthController` için kapsamlı birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/auth/models/avatar_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/models/avatar_model.dart): Hazır ve dosya profil resmi veri modelini tanımlar.
- [lib/features/auth/models/user_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/models/user_model.dart): Kullanıcı bilgilerini ve hashli şifresini saklayan modeldir.
- [lib/features/auth/controllers/auth_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/controllers/auth_controller.dart): Kimlik doğrulama ve oturum durumunu yöneten controller'dır.
- [lib/features/auth/widgets/password_field.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/widgets/password_field.dart): Şifre göster/gizle durumunu yöneten güvenli giriş alanıdır.
- [lib/features/auth/widgets/auth_header.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/widgets/auth_header.dart): Giriş ve kayıt ekranlarında tepe logo ve başlık bileşenidir.
- [lib/features/auth/widgets/register_form_fields.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/widgets/register_form_fields.dart): Kayıt formu giriş alanlarını içeren modüler widget'tır.
- [lib/features/auth/widgets/login_form_fields.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/widgets/login_form_fields.dart): Giriş formu giriş alanlarını içeren modüler widget'tır.
- [test/features/auth/auth_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/auth/auth_controller_test.dart): AuthController kayıt, giriş ve oturum birim testleridir.

**Güncellenen:**
- [lib/features/auth/views/register_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/views/register_view.dart): Tam fonksiyonel kayıt ekranı oluşturuldu.
- [lib/features/auth/views/login_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/auth/views/login_view.dart): Tam fonksiyonel giriş ekranı oluşturuldu.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 23 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- Geliştirme kolaylığı için PROJECT.md Bölüm 12.2 gereğince `AuthController.testEmail` ve hızlı giriş desteği eklendi.
- Kayıt başarılı olduğunda kullanıcı doğrudan oturum açmış sayılarak `/home` ekranına yönlendirildi.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 3 – Ayarlar Modülü (`features/settings`)

### Yapılanlar
- `AppSettingsModel` (tema modu ve dil seçimi) modeli oluşturuldu.
- Hazır avatar PNG asset'leri (`assets/avatars/avatar_1.png` - `avatar_4.png`) oluşturuldu.
- `SettingsController` iş mantığı kodlandı: tema modu değiştirme, dil seçimi değiştirme, avatar güncelleme ve hesap profili güncelleme.
- `UserAvatarWidget` geliştirildi: Hazır avatar (asset), yüklenen dosya (File) ve e-posta baş harfi desteği.
- `AvatarPickerBottomSheet` yazıldı: Hazır avatarlar, galeriden ve kameradan resim seçip uygulama dizinine kaydetme desteği.
- `ProfileHeaderCard` kullanıcı bilgileri özeti (e-posta, formatlı telefon, kayıt tarihi, avatar) geliştirildi.
- `ThemeSelectorCard` (Koyu / Aydınlık seçimi) ve `LanguageSelectorCard` (TR / EN seçimi) anında uygulanır ve kalıcı olarak yazılır şekilde yapıldı.
- `AccountUpdateBottomSheet` kodlandı: E-posta, telefon ve şifre güncelleme (mevcut şifre doğrulamalı).
- `SettingsView` ekranı Material 3 standartlarında tamamlandı; onay diyaloglu çıkış yapma mekanizması bağlandı.
- `SettingsController` birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/settings/models/app_settings_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/models/app_settings_model.dart): Tema modu ve dil tercihlerini saklayan modeldir.
- [lib/features/settings/controllers/settings_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/controllers/settings_controller.dart): Ayarlar ve profil durumunu yöneten controller'dır.
- [lib/features/settings/widgets/user_avatar_widget.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/user_avatar_widget.dart): Profil resmi gösterimini sağlayan ortak avatar bileşenidir.
- [lib/features/settings/widgets/avatar_picker_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/avatar_picker_bottom_sheet.dart): Hazır ve özel profil resmi seçme alt sayfasıdır.
- [lib/features/settings/widgets/profile_header_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/profile_header_card.dart): Kullanıcı profil özeti kartıdır.
- [lib/features/settings/widgets/theme_selector_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/theme_selector_card.dart): Tema seçim kartıdır.
- [lib/features/settings/widgets/language_selector_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/language_selector_card.dart): Çoklu dil seçim kartıdır.
- [lib/features/settings/widgets/account_update_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/account_update_bottom_sheet.dart): Kullanıcı bilgileri ve şifre güncelleme formudur.
- [test/features/settings/settings_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/settings/settings_controller_test.dart): SettingsController tema, dil ve profil güncelleme birim testleridir.

**Güncellenen:**
- [lib/features/settings/views/settings_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/views/settings_view.dart): Tam fonksiyonel ayarlar ekranı kodlandı.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 28 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- Profil resmi galeriden veya kameradan seçildiğinde `path_provider` ile kalıcı uygulama dizinine kopyalanıp `AvatarModel(type: AvatarType.file)` olarak saklanması sağlandı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 4 – Harcamalar Modülü (`features/expenses`)

### Yapılanlar
- `ExpenseModel` ve `ExpenseCategory` enum'ı oluşturuldu (7 kategori: market, transport, bills, entertainment, health, education, other).
- İkon, renk ve yerelleştirilmiş kategori etiket uzantıları (`ExpenseCategoryX`) bağlandı.
- `ExpensesController` kodlandı: Harcama ekleme, silme, geri alma (`restoreExpense`), ay filtresi, tarihe göre gruplama, aylık ve kategori toplamları, son 7 gün analizi.
- `ExpenseTile` geliştirildi: Renkli ikon, not, tarih, kuruş formatlı para metni ve kaydırarak silme (`Dismissible`).
- `ExpenseMonthFilter` bileşeni yazıldı: Ay navigasyonu ve o aya ait toplam tutar gösterge çubuğudur.
- `AddExpenseBottomSheet` formu yazıldı: Kuruş dönüşümlü tutar girişi, kategori seçim chip'leri, tarih seçici ve not alanı.
- `ExpensesView` ana ekranı tamamlandı: Tarihe göre gruplanmış harcama listesi, boş durum ekranı, SnackBar geri al butonu ve FAB ile harcama ekleme.
- `ExpensesController` için birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/expenses/models/expense_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/models/expense_model.dart): Harcama kaydı ve kategorileri veri modelidir.
- [lib/features/expenses/controllers/expenses_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/controllers/expenses_controller.dart): Harcama durumunu ve kalıcı depolamayı yöneten controller'dır.
- [lib/features/expenses/widgets/expense_tile.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/widgets/expense_tile.dart): Tek bir harcama satırı ve kaydırarak silme bileşenidir.
- [lib/features/expenses/widgets/expense_month_filter.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/widgets/expense_month_filter.dart): Ay navigasyonu ve o aya ait toplam tutar gösterge çubuğudur.
- [lib/features/expenses/widgets/add_expense_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/widgets/add_expense_bottom_sheet.dart): Yeni harcama ekleme modal formudur.
- [lib/features/expenses/views/expenses_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/views/expenses_view.dart): Harcamalar ana ekranıdır.
- [test/features/expenses/expenses_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/expenses/expenses_controller_test.dart): Harcama ekleme, silme, geri alma, ay filtreleme ve kategori toplamları birim testleridir.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 33 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- Harcamalar listesi tarihe göre gruplanmış (her gün başlığı altında o günün harcamaları) ve tarihe göre azalan sırada listelendi.
- Yanlışlıkla silmelere karşı `SnackBarAction` ile "Geri Al" (Undo) desteği sunuldu.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 5 – Bütçe & İstatistik Modülü (`features/budget`)

### Yapılanlar
- `BudgetModel` modeli oluşturuldu (`monthKey` ve kuruş bazlı `limitAmount`).
- `BudgetController` kodlandı: Aylık limit belirleme, harcanan, kalan ve bütçe aşım hesapları, kategori dağılımı ve son 7 gün harcama haritası.
- Harici paket kullanılmadan Flutter çekirdek API'si ile `DonutChartPainter` (halka grafik) ve `WeeklyBarChartPainter` (haftalık çubuk grafik) `CustomPainter` sınıfları kodlandı.
- `BudgetSummaryCard` (limit, harcanan, kalan ve limit aşım uyarısı), `CategoryDistributionCard` (halka grafik + renkli etiketli lejant), `WeeklyChartCard` (son 7 gün çubuk grafik) ve `SetBudgetDialog` bileşenleri geliştirildi.
- `BudgetView` ana ekranı tamamlandı.
- `BudgetController` birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/budget/models/budget_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/models/budget_model.dart): Aylık bütçe limit veri modelidir.
- [lib/features/budget/controllers/budget_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/controllers/budget_controller.dart): Bütçe limitlerini ve istatistik hesaplarını yöneten controller'dır.
- [lib/features/budget/widgets/donut_chart_painter.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/donut_chart_painter.dart): CustomPainter ile çizilen kategori dağılım halka grafiğidir.
- [lib/features/budget/widgets/weekly_bar_chart_painter.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/weekly_bar_chart_painter.dart): CustomPainter ile çizilen son 7 gün harcama çubuk grafiğidir.
- [lib/features/budget/widgets/budget_summary_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/budget_summary_card.dart): Bütçe limiti, harcanan ve kalan tutar kartıdır.
- [lib/features/budget/widgets/category_distribution_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/category_distribution_card.dart): Kategori halka grafiği ve lejant kartıdır.
- [lib/features/budget/widgets/weekly_chart_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/weekly_chart_card.dart): Haftalık harcama grafiği kartıdır.
- [lib/features/budget/widgets/set_budget_dialog.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/set_budget_dialog.dart): Bütçe limiti belirleme/güncelleme diyalogudur.
- [lib/features/budget/views/budget_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/views/budget_view.dart): Bütçe & İstatistik ana ekranıdır.
- [test/features/budget/budget_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/budget/budget_controller_test.dart): Bütçe hesaplama ve limit güncelleme birim testleridir.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 37 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- PROJECT.md 6.1 ve 8.4 maddeleri gereğince harici grafik kütüphaneleri kullanılmayıp `CustomPainter` ile çizim yapıldı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 6 – Finansal Hedeflerim Modülü (`features/goals`)

### Yapılanlar
- `GoalModel` ve `GoalStepModel` immutable modelleri oluşturuldu (`savedAmount`, `progress` ve `isReached` türetilmiş getter olarak tanımlandı).
- `GoalsController` kodlandı: Hedef oluşturma, hedefe para ekleme (`addStep`), hedef silme ve en yakın hedefi bulma (`getNearestGoal`).
- `GoalCard` (hedef başlığı, biriken/hedef tutar, yüzde, ilerleme çubuğu, tamamlandı rozeti ve para ekleme butonu) geliştirildi.
- `AddGoalBottomSheet` (hedef adı ve hedef tutar) ve `AddMoneyBottomSheet` (tutar ve opsiyonel not) modal formları kodlandı.
- `GoalDetailBottomSheet` geliştirildi: Birikim adımları geçmişi, para ekleme ve onay diyaloglu hedef silme.
- `GoalsView` ana ekranı tamamlandı (boş durum ekranı ve FloatingActionButton eklendi).
- `GoalsController` birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/goals/models/goal_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/models/goal_model.dart): Finansal hedef ve birikim adımları veri modelleridir.
- [lib/features/goals/controllers/goals_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/controllers/goals_controller.dart): Hedefler durumunu ve adımlarını yöneten controller'dır.
- [lib/features/goals/widgets/goal_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/widgets/goal_card.dart): Hedef kartı bileşenidir.
- [lib/features/goals/widgets/add_goal_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/widgets/add_goal_bottom_sheet.dart): Yeni hedef oluşturma modal formudur.
- [lib/features/goals/widgets/add_money_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/widgets/add_money_bottom_sheet.dart): Hedefe para ekleme modal formudur.
- [lib/features/goals/widgets/goal_detail_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/widgets/goal_detail_bottom_sheet.dart): Hedef detayları ve birikim adımları geçmişi alt sayfasıdır.
- [lib/features/goals/views/goals_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/views/goals_view.dart): Hedefler ana ekranıdır.
- [test/features/goals/goals_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/goals/goals_controller_test.dart): Hedef ekleme, para adımı ekleme, silme ve en yakın hedef birim testleridir.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 42 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- PROJECT.md Bölüm 6.3 kuralı uyarınca `savedAmount` ve `progress` JSON'da tutulmayıp modellerde getter olarak hesaplandı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 7 – 10 Günlük Challenge & Streak Modülü (`features/challenge`)

### Yapılanlar
- `ChallengeModel` ve `ChallengeTaskModel` veri modelleri oluşturuldu (`dayNumber`, `title`, `description`, `completedAt`, `isCompleted` getter'ı).
- `ChallengeController` kodlandı: 10 günlük hazır şablondan başlatma, takvim gününe göre kilit/görev/kaçırıldı/tamamlandı durumları (`getTaskStatus`), bugünün görevini tamamlama (`completeToday`), seri (streak) artışı veya kaçırılma durumunda sıfırlanma, en iyi seriyi koruma (`bestStreak`) ve yeniden başlatma.
- `ChallengeHeaderCard` (gün sayacı, güncel ve en iyi streak, genel ilerleme çubuğu), `ChallengeTaskTile` (durum rozetleri, bugünün görevi için "Görevi Tamamla" aksiyonu) ve tamamlama diyalogu geliştirildi.
- `ChallengeView` ana ekranı kodlandı.
- `ChallengeController` birim testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/features/challenge/models/challenge_model.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/models/challenge_model.dart): 10 günlük challenge ve günlük görev veri modelleridir.
- [lib/features/challenge/controllers/challenge_controller.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/controllers/challenge_controller.dart): Challenge durumunu, görev tamamlama ve streak mantığını yöneten controller'dır.
- [lib/features/challenge/widgets/challenge_header_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/widgets/challenge_header_card.dart): Challenge başlık, gün sayacı ve streak gösterge kartıdır.
- [lib/features/challenge/widgets/challenge_task_tile.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/widgets/challenge_task_tile.dart): Günlük görev kartı ve tamamlama butonudur.
- [lib/features/challenge/views/challenge_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/views/challenge_view.dart): 10 Günlük Challenge ana ekranıdır.
- [test/features/challenge/challenge_controller_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/challenge/challenge_controller_test.dart): Challenge başlatma, görev durumu, streak artışı/sıfırlanması ve yeniden başlatma birim testleridir.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 48 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- PROJECT.md Bölüm 6.3 kurallarına göre takvim günü hesabı `startDate.dateOnly` baz alınarak yapıldı ve gelecek günler kilitlendi.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 8 – Ana Kabuk & Ana Panel (`features/home`, `features/dashboard`)

### Yapılanlar
- `MockDataLoader` geliştirildi: İlk kurulumda veya test kullanıcısında boş kalan depolamaya gerçekçi harcama, bütçe, hedef ve aktif challenge verisi yüklemesi sağlandı.
- `DashboardWelcomeHeader` (kullanıcı karşılama ve avatar tıklama), `DashboardBudgetCard` (bu ayki kalan bütçe), `DashboardChallengeCard` (bugünkü görev ve streak), `DashboardGoalCard` (en yakın hedefin ilerleme çubuğu) ve `DashboardRecentExpenses` (son harcamalar ve tümünü gör aksiyonu) bileşenleri kodlandı.
- `DashboardView` ana paneli tamamlandı; kartlara dokunulduğunda doğrudan ilgili sekmenin açılması bağlandı (`onNavigateToTab`).
- `HomeShellView` tamamlandı: `IndexedStack` ile 5 ana sekme (Panel, Challenge, Hedeflerim, Harcamalar, Bütçe) ve `NavigationBar` entegrasyonu sağlandı.
- Ortak controller'ların yaşam döngüsü kabukta yönetildi ve sekmeler arası senkronizasyon garanti altına alındı.
- `MockDataLoader` ve `HomeShellView` için widget ve entegrasyon testleri yazıldı ve doğrulandı.

### Dosyalar
**Oluşturulan:**
- [lib/core/services/mock_data_loader.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/services/mock_data_loader.dart): Proje ilk açılışında örnek gerçekçi verileri yükleyen servistir.
- [lib/features/dashboard/widgets/dashboard_welcome_header.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_welcome_header.dart): Karşılama başlığı ve profil avatarı bileşenidir.
- [lib/features/dashboard/widgets/dashboard_budget_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_budget_card.dart): Kalan bütçe özet kartıdır (Bütçe sekmesine yönlendirir).
- [lib/features/dashboard/widgets/dashboard_challenge_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_challenge_card.dart): Günlük challenge görevi ve streak kartıdır (Challenge sekmesine yönlendirir).
- [lib/features/dashboard/widgets/dashboard_goal_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_goal_card.dart): En yakın hedefin ilerleme çubuğu kartıdır (Hedeflerim sekmesine yönlendirir).
- [lib/features/dashboard/widgets/dashboard_recent_expenses.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_recent_expenses.dart): Son harcamalar listesi ve yönlendirme kartıdır.
- [lib/features/dashboard/views/dashboard_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/views/dashboard_view.dart): Ana panel ekranıdır.
- [test/features/dashboard/dashboard_view_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/dashboard/dashboard_view_test.dart): MockDataLoader birim testidir.
- [test/features/home/home_shell_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/home/home_shell_test.dart): HomeShellView sekme yönetimi widget testidir.

**Güncellenen:**
- [lib/features/home/views/home_shell_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/home/views/home_shell_view.dart): 5 ana sekmenin bağlandığı tam fonksiyonel ana kabuk kodlandı.
- [lib/main.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/main.dart): Açılışta MockDataLoader çağrısı eklendi.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 50 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- Sekmeler arası gezinmeyi kolaylaştırmak için ana paneldeki kartlara tıklandığında `onNavigateToTab` fonksiyonuyla ilgili sekmeye yumuşak geçiş sağlandı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 9 – Uygulama İkonu, Açılış Ekranı (Splash) ve Platform Ayarları

### Yapılanlar
- Platform seviyesinde uygulama adı "Money Habit" olarak yapılandırıldı (iOS `CFBundleDisplayName`, Android `android:label`, macOS `PRODUCT_NAME`, Web `manifest.json`).
- iOS kamera ve fotoğraf kitaplığı izin açıklamaları (`NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`) `Info.plist` dosyasına eklendi.
- Yüksek çözünürlüklü uygulama ikonu ve splash ekranı görselleri (`app_icon.svg`, `app_icon.png`, `app_icon_foreground.png`, `splash_logo.png`) Gece Finans Paletine (Deep Navy arka plan, Emerald yaprak/para simgesi) uygun şekilde oluşturuldu.
- `pubspec.yaml` içerisinde `flutter_launcher_icons` ve `flutter_native_splash` ayarları yapılandırıldı.
- `dart run flutter_launcher_icons` komutu çalıştırılarak tüm iOS ve Android uygulama ikonları oluşturuldu.
- `dart run flutter_native_splash:create` komutu çalıştırılarak yerel splash ekranları (gece ve gündüz varyantları dahil) oluşturuldu.

### Dosyalar
**Oluşturulan:**
- [assets/icons/app_icon.svg](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/assets/icons/app_icon.svg): Vektörel uygulama logo tasarımıdır.
- [assets/icons/app_icon.png](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/assets/icons/app_icon.png): 1024x1024 uygulama ikonudur.
- [assets/icons/app_icon_foreground.png](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/assets/icons/app_icon_foreground.png): Android Adaptive Icon ön plan görselidir.
- [assets/icons/splash_logo.png](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/assets/icons/splash_logo.png): Splash ekranı logo görselidir.

**Güncellenen:**
- [pubspec.yaml](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/pubspec.yaml): `flutter_launcher_icons` ve `flutter_native_splash` konfigürasyonları eklendi.
- [ios/Runner/Info.plist](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/ios/Runner/Info.plist): Uygulama adı "Money Habit" yapıldı ve izin metinleri eklendi.
- [android/app/src/main/AndroidManifest.xml](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/android/app/src/main/AndroidManifest.xml): Uygulama adı "Money Habit" olarak ayarlandı.
- [macos/Runner/Configs/AppInfo.xcconfig](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/macos/Runner/Configs/AppInfo.xcconfig): Ürün adı "Money Habit" olarak ayarlandı.
- [web/manifest.json](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/web/manifest.json): Uygulama adı ve kısa adı "Money Habit" olarak ayarlandı.

### Doğrulama
- `dart run flutter_launcher_icons`: Başarıyla çalıştı ve tüm mipmap/AssetCatalog ikonları güncellendi.
- `dart run flutter_native_splash:create`: Başarıyla çalıştı, Android XML ve iOS LaunchScreen varlıkları üretildi.
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 50 testin tamamı başarılı bir şekilde geçti.

### Alınan Kararlar
- PROJECT.md Bölüm 7 ve 8.1 gereksinimleri eksiksiz karşılandı.
- Splash arka planı Gece Finans Paletinin ana arka plan rengi `#0D1527` (AppColors.bgDark) olarak ayarlandı.

### Açık Konular
- Yok.

---

## [2026-10-23] Aşama 10 – Uçtan Uca Test, Statik Analiz ve Final Doğrulama

### Yapılanlar
- Tüm kod tabanında Flutter statik analiz (`flutter analyze`) çalıştırıldı; 0 hata ve 0 uyarı ile tamamlandı.
- Çekirdek yardımcılar, servisler, controller'lar ve widget'ları kapsayan 50 birim ve widget testinin tamamı (`flutter test`) çalıştırıldı ve hepsi başarıyla geçti.
- iOS Simülatörü (`iPhone 18 Pro`, ID: `E8204135-65EB-435D-812A-B84397808992`) üzerinde `flutter build ios --simulator` ile native derleme yapıldı (0 hata ile `Runner.app` üretildi).
- Simülatör üzerinde `flutter run -d E8204135-65EB-435D-812A-B84397808992` ile uygulama başarıyla ayağa kaldırıldı, Impeller (Metal) motoru ile ilk kare sorunsuz render edildi.
- Simülatörden ekran görüntüsü alınarak Gece Finans Paleti, tipografi, butonlar ve form alanlarının Material 3 tasarımına tam uyumu doğrulandı.

### Dosyalar
**Oluşturulan:**
- [DONE.md](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/DONE.md): Tüm geliştirme ve doğrulama adımlarının kayıt defteri güncellendi.

### Doğrulama
- `flutter analyze`: `No issues found!` (0 hata, 0 uyarı).
- `flutter test`: 50 testin 50'si de başarılı (`All tests passed!`).
- `flutter build ios --simulator`: Başarılı derleme (`Built build/ios/iphonesimulator/Runner.app`).
- `flutter run`: iPhone 18 Pro simülatöründe sorunsuz başlatıldı ve çalıştırıldı.

### Alınan Kararlar
- Proje, PROJECT.md ve `.agents/skills` içindeki tüm teknik ve mimari kısıtlara (ValueNotifier tekil state yönetimi, çekirdek Navigator, LocalStorageService kalıcılığı, kuruş bazlı int para mimarisi, CustomPainter grafikler, gen-l10n çoklu dil) %100 sadık kalınarak tamamlandı.

### Açık Konular
- Yok.

---

## [2026-10-23] Düzeltme – Karanlık ve Aydınlık Mod Okunabilirlik ve Tipografi İyileştirmesi

### Yapılanlar
- Karanlık ve aydınlık modlarda görülen metin okunabilirlik ve kontrast sorunları giderildi.
- Temada ikincil/açıklama metinlerine yanlışlıkla atanmış olan `colorScheme.outline` (çerçeve rengi) referansları tespit edildi; yerine Material 3 standartlarında yüksek kontrastlı `colorScheme.onSurfaceVariant` bağlandı.
- `AppColors` paletinde tipografi renkleri optimize edildi:
  - Karanlık Mod: `darkTextPrimary` (#F8FAFC) ve `darkTextSecondary` (#94A3B8, koyu lacivert zemin üzerinde keskin ve net gümüş-mavi).
  - Aydınlık Mod: `lightTextPrimary` (#0F172A) ve `lightTextSecondary` (#475569, beyaz zemin üzerinde >7:1 WCAG AAA kontrastlı arduvaz grisi).
  - Buton ve avatar üzerindeki yazı rengi (`darkOnPrimary`) beyaz (#FFFFFF) yapılarak zümrüt yeşili zemin üzerinde kristal berraklık sağlandı.
- `AppTheme.dark` ve `AppTheme.light` içinde eksiksiz `TextTheme`, `SegmentedButtonThemeData`, `ChipThemeData`, `IconThemeData`, `ListTileThemeData` ve `InputDecorationTheme` yapılandırıldı.
- `DashboardView`, `BudgetSummaryCard`, `CategoryDistributionCard`, `WeeklyChartCard`, `DashboardChallengeCard`, `ChallengeHeaderCard`, `ChallengeTaskTile`, `ProgressBarCard`, `ExpenseTile`, `ExpensesView`, `ProfileHeaderCard`, `EmptyStateWidget` ve Auth ekranlarındaki metin/ikon stilleri güncellendi.
- `IndexedStack` içindeki `ExpensesView` ve `GoalsView` için FloatingActionButton `heroTag` çakışması (`fab_expenses`, `fab_goals`) düzeltildi.
- Ana sekmelerin AppBar bileşenlerine `automaticallyImplyLeading: false` eklenerek ana panelde beliren geri tuşu kaldırıldı.
- Kapsamlı `readability_test.dart` yazılarak her iki tema modunda tüm 5 ana sekme, ayarlar ve kimlik doğrulama ekranları test edildi.

### Dosyalar
**Oluşturulan:**
- [test/features/theme/readability_test.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/test/features/theme/readability_test.dart): Karanlık ve aydınlık modda tüm ekranların render ve kontrast birim/widget testidir.

**Güncellenen:**
- [lib/core/constants/app_colors.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/constants/app_colors.dart): Tipografi ve zemin kontrast renkleri güçlendirildi.
- [lib/core/theme/app_theme.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/theme/app_theme.dart): `TextTheme`, `onSurfaceVariant`, `chipTheme`, `segmentedButtonTheme` ve `inputDecorationTheme` entegre edildi.
- [lib/features/dashboard/widgets/dashboard_welcome_header.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_welcome_header.dart): Karşılama alt başlık stili düzeltildi.
- [lib/features/dashboard/widgets/dashboard_budget_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_budget_card.dart): Bütçe başlık ve harcanan/limit etiket renkleri düzeltildi.
- [lib/features/dashboard/widgets/dashboard_challenge_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_challenge_card.dart): Görev açıklaması ve radyo butonu renkleri düzeltildi.
- [lib/features/dashboard/widgets/dashboard_recent_expenses.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/widgets/dashboard_recent_expenses.dart): Harcama tarihi ve boş liste metin rengi düzeltildi.
- [lib/core/widgets/progress_bar_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/progress_bar_card.dart): Alt başlık ve hedef tutar metin renkleri düzeltildi.
- [lib/core/widgets/empty_state_widget.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/core/widgets/empty_state_widget.dart): İkon ve açıklama kontrastı düzeltildi.
- [lib/features/settings/widgets/profile_header_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/settings/widgets/profile_header_card.dart): Telefon ve kayıt tarihi renkleri düzeltildi.
- [lib/features/goals/widgets/goal_detail_bottom_sheet.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/widgets/goal_detail_bottom_sheet.dart): Adım tarihi ve boş durum metin rengi düzeltildi.
- [lib/features/expenses/views/expenses_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/views/expenses_view.dart): Tarih grup başlığı ve FAB heroTag düzeltildi.
- [lib/features/expenses/widgets/expense_tile.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/expenses/widgets/expense_tile.dart): Harcama tarihi rengi düzeltildi.
- [lib/features/challenge/widgets/challenge_header_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/widgets/challenge_header_card.dart): En iyi seri metin rengi düzeltildi.
- [lib/features/challenge/widgets/challenge_task_tile.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/challenge/widgets/challenge_task_tile.dart): Görev açıklaması, kilitli ikon ve kaçırıldı durumu düzeltildi.
- [lib/features/budget/widgets/budget_summary_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/budget_summary_card.dart): Harcanan ve kalan etiket renkleri düzeltildi.
- [lib/features/budget/widgets/category_distribution_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/category_distribution_card.dart): Kategori yüzdesi ve boş veri metin rengi düzeltildi.
- [lib/features/budget/widgets/weekly_chart_card.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/budget/widgets/weekly_chart_card.dart): Grafik altı gün etiketleri rengi düzeltildi.
- [lib/features/goals/views/goals_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/goals/views/goals_view.dart): FAB heroTag eklendi.
- [lib/features/dashboard/views/dashboard_view.dart](file:///Users/knetrix/Desktop/MAIN/Kurslar/SoftITo/GithubRepo/SoftITo-Projects-Other/Money-Habit-Tracker-WithSkill/lib/features/dashboard/views/dashboard_view.dart): AppBar geri tuşu gizlendi.

### Doğrulama
- `flutter analyze`: 0 hata, 0 uyarı (temiz).
- `flutter test`: 56 testin 56'sı da başarılı (`All tests passed!`).
- Simülatör ekran görüntüleri ile karanlık ve aydınlık modda yüksek kontrast ve kusursuz okunabilirlik doğrulandı.

### Alınan Kararlar
- Metin renklerinde `outline` kullanılmayacak; her zaman `onSurface` (ana metinler) ve `onSurfaceVariant` (ikincil ve açıklama metinleri) tercih edilecek.

### Açık Konular
- Yok.

---

## [2026-10-23] README ve Ekran Görüntüleri (iOS Simülatör)

### Yapılanlar
- Varsayılan Flutter README'si, Kitalog README düzenine (görsel tablolar, ek görüntüler, Özellikler, Kurulum ve çalıştırma, Mimari, Notlar) uygun şekilde yeniden yazıldı.
- Uygulama iOS Simülatöründe (iPhone 18 Pro) çalıştırılarak 14 ekran görüntüsü alındı: kayıt, giriş, ana panel, challenge, hedefler, hedef detayı, yeni hedef, harcamalar, yeni harcama, bütçe, bütçe limiti, ayarlar, aydınlık tema ve İngilizce bütçe.
- Görüntüler temiz tohum verisiyle, ekranı Mac'teki bir yapılandırma dosyasından seçen geçici bir giriş noktası (`tool/screenshot_main.dart`) ile alındı; bu dosya iş bitince silindi.
- Ana kabuğa `initialIndex` parametresi eklendi (ekran görüntüsü için; varsayılan davranış değişmedi).

### Dosyalar
**Oluşturulan:**
- [docs/screenshots/](docs/screenshots/): iOS Simülatöründen alınan 14 ekran görüntüsünü (koyu/aydınlık tema, Türkçe/İngilizce) içerir.

**Güncellenen:**
- [README.md](README.md): Ekran görüntüsü tabloları, özellikler, kurulum, mimari ve notlarla yeniden yazıldı.
- [lib/features/home/views/home_shell_view.dart](lib/features/home/views/home_shell_view.dart): Varsayılanı 0 olan `initialIndex` parametresi eklendi.

**Silinen:**
- `tool/screenshot_main.dart`: Ekran görüntüleri için geçici olarak yazılıp silinen giriş noktasıydı.

### Doğrulama
- `flutter analyze`: 0 sorun.
- `flutter test`: 56 testin 56'sı başarılı.
- **iOS Simulator:** Tüm ekran görüntüleri tek tek açılıp gözle kontrol edildi.

### Alınan Kararlar
- Üretim koduna ekran görüntüsü modu eklenmedi; yalnızca varsayılan davranışı değiştirmeyen `initialIndex` parametresi eklendi.

### Açık Konular
- İngilizcede yüzdelerin Türkçe biçimde (`%25`) görünmesi sorunu bir sonraki kayıtta çözüldü.

---

## [2026-10-23] Yüzde Biçiminin Dile Göre Gösterilmesi

### Yapılanlar
- Yüzdeler sabit `%` önekiyle yazıldığı için İngilizcede de `%25` görünüyordu; `intl` `NumberFormat.percentPattern` kullanan `toPercent` uzantısı eklendi (Türkçe `%25`, İngilizce `25%`).
- Kategori dağılımı, hedef kartı, hedef detayı ve ilerleme kartındaki yüzdeler bu uzantıya taşındı.
- İngilizce bütçe ekran görüntüsü yeniden alındı.

### Dosyalar
**Oluşturulan:**
- [lib/core/extensions/percent_extensions.dart](lib/core/extensions/percent_extensions.dart): Yüzdeyi seçili dile göre biçimlendiren uzantıyı sunar.

**Güncellenen:**
- [lib/features/budget/widgets/category_distribution_card.dart](lib/features/budget/widgets/category_distribution_card.dart): Kategori yüzdeleri dile göre biçimlendirildi.
- [lib/features/goals/widgets/goal_card.dart](lib/features/goals/widgets/goal_card.dart): Hedef yüzdesi dile göre biçimlendirildi.
- [lib/features/goals/widgets/goal_detail_bottom_sheet.dart](lib/features/goals/widgets/goal_detail_bottom_sheet.dart): Hedef detayındaki yüzde dile göre biçimlendirildi.
- [lib/core/widgets/progress_bar_card.dart](lib/core/widgets/progress_bar_card.dart): İlerleme yüzdesi dile göre biçimlendirildi.
- [test/core/utils/validators_test.dart](test/core/utils/validators_test.dart): `toPercent` için Türkçe/İngilizce birim testi eklendi.
- [docs/screenshots/14-budget-en.png](docs/screenshots/14-budget-en.png): İngilizce yüzde biçimiyle yeniden çekildi.

### Doğrulama
- `flutter analyze`: 0 sorun.
- `flutter test`: 57 testin 57'si başarılı.
- **iOS Simulator:** İngilizce bütçe ve hedef ekranlarında `25%` / `50%`, Türkçede `%50` göründüğü kontrol edildi.

### Alınan Kararlar
- Yüzde biçimi l10n metnine değil, para biçimindeki `toCurrency` gibi `intl` yerel ayarına bırakıldı.

### Açık Konular
- Yok.

---

## Final Özet

- **Tamamlananlar:**
  - **Aşama 1-10 ve Okunabilirlik Düzeltmesi:** Tüm fonksiyonel modüller, Material 3 tema entegrasyonu, yerel kalıcılık, 57 birim/widget testi ve iOS simülatör doğrulama tamamlandı.
- **Bilinen Eksikler:** Yok.
- **Projenin Nasıl Çalıştırılacağı:**
  ```bash
  flutter pub get
  flutter gen-l10n
  flutter analyze
  flutter test
  flutter run
  ```
