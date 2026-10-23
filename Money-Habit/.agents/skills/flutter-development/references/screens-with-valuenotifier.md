# Screens with ValueNotifier

## 1. View Yaşam Döngüsü + ValueListenableBuilder

View `StatefulWidget`'tır Sadece Controller'ın Yaşam Döngüsünü Yönetmek için; `setState` Çağrılmaz.

```dart
// lib/features/expenses/views/expenses_view.dart
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../controllers/expenses_controller.dart';
import '../models/expense_model.dart';
import '../widgets/expense_tile.dart';

class ExpensesView extends StatefulWidget {
  final LocalStorageService storage;

  const ExpensesView({super.key, required this.storage});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  late final ExpensesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpensesController(widget.storage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navExpenses),
        actions: const [SettingsActionButton()],
      ),
      body: ValueListenableBuilder<List<ExpenseModel>>(
        valueListenable: _controller.expenses,
        builder: (context, expenses, _) {
          if (expenses.isEmpty) {
            return EmptyStateWidget(message: context.l10n.expensesEmpty);
          }
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) => ExpenseTile(
              expense: expenses[index],
              onDismissed: () => _controller.removeExpense(expenses[index].id),
            ),
          );
        },
      ),
    );
  }
}
```

## 2. Ayarlar İkonu (Tüm Ana Sekmelerde Ortak)

```dart
// lib/core/widgets/settings_action_button.dart
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../router/app_router.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.settingsTitle,
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
    );
  }
}
```

## 3. Ortak Validator'lar (Kayıt + Ayarlar)

Validator'lar `BuildContext` Almaz; Hata **Anahtarı** Döner, View Bunu l10n Metnine Çevirir. Böylece Saf Dart Olarak Birim Test Edilebilir.

```dart
// lib/core/utils/validators.dart
enum ValidationError { required, invalidEmail, invalidPhone, weakPassword, passwordMismatch }

abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _strongPassword = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  static ValidationError? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (!_email.hasMatch(v)) return ValidationError.invalidEmail;
    return null;
  }

  /// 05XX..., +905XX..., 5XX... -> 5XXXXXXXXX (10 hane)
  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length == 12) digits = digits.substring(2);
    if (digits.startsWith('0') && digits.length == 11) digits = digits.substring(1);
    return digits;
  }

  static ValidationError? phone(String? value) {
    final v = normalizePhone(value ?? '');
    if (v.isEmpty) return ValidationError.required;
    if (v.length != 10 || !v.startsWith('5')) return ValidationError.invalidPhone;
    return null;
  }

  static ValidationError? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (!_strongPassword.hasMatch(v)) return ValidationError.weakPassword;
    return null;
  }

  static ValidationError? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return ValidationError.required;
    if (value != original) return ValidationError.passwordMismatch;
    return null;
  }
}
```

```dart
// lib/core/extensions/validation_l10n_extension.dart
extension ValidationErrorText on ValidationError {
  String message(AppLocalizations l10n) => switch (this) {
        ValidationError.required => l10n.errorRequired,
        ValidationError.invalidEmail => l10n.errorInvalidEmail,
        ValidationError.invalidPhone => l10n.errorInvalidPhone,
        ValidationError.weakPassword => l10n.errorWeakPassword,
        ValidationError.passwordMismatch => l10n.errorPasswordMismatch,
      };
}
```

## 4. Form Alanları: Klavye Tipi ve Formatlama

```dart
// lib/features/auth/widgets/register_form_fields.dart (parça)
TextFormField(
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  autocorrect: false,
  autofillHints: const [AutofillHints.email],
  decoration: InputDecoration(
    labelText: context.l10n.emailLabel,
    prefixIcon: const Icon(Icons.email_outlined),
  ),
  validator: (v) => Validators.email(v)?.message(context.l10n),
),
TextFormField(
  controller: phoneController,
  keyboardType: TextInputType.phone,
  textInputAction: TextInputAction.next,
  autofillHints: const [AutofillHints.telephoneNumber],
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11), // 05XXXXXXXXX
  ],
  decoration: InputDecoration(
    labelText: context.l10n.phoneLabel,
    hintText: '5XX XXX XX XX',
    prefixIcon: const Icon(Icons.phone_outlined),
  ),
  validator: (v) => Validators.phone(v)?.message(context.l10n),
),
// Şifre alanı: obscureText + göster/gizle -> yerel UI durumu olduğu için
// küçük bir StatefulWidget (PasswordField) içinde tutulur.
```

```dart
// Tutar alanı (harcama / hedef / para ekle)
TextFormField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
  decoration: InputDecoration(labelText: context.l10n.amountLabel, suffixText: '₺'),
  validator: (v) => v?.toKurus() == null ? context.l10n.errorInvalidAmount : null,
)
```

## 5. Gönderim Akışı

```dart
Future<void> _onSubmit() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;
  final success = await _controller.register(
    email: _emailController.text,
    phone: _phoneController.text,
    password: _passwordController.text,
  );
  if (!mounted) return;
  if (success) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }
}
```

- Yükleme / Hata Durumu Controller State'inde (`status`, `errorKey`) Tutulur; View Sadece Gösterir.
- `TextEditingController`'lar View `dispose()` İçinde Kapatılır.
- SnackBar / Dialog `ScaffoldMessenger.of(context)` ile, `mounted` Kontrolünden Sonra Gösterilir.
