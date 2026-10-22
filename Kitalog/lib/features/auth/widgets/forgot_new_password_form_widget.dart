import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/password_form_field.dart';
import 'auth_form_actions_widget.dart';

/// Şifremi unuttum 2. adım: yeni şifre ve tekrarı (kayıt ekranıyla aynı şifre kuralları).
class ForgotNewPasswordFormWidget extends StatefulWidget {
  const ForgotNewPasswordFormWidget({
    super.key,
    required this.email,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  /// Doğrulanan hesabın e-postası (kullanıcı hangi hesap için şifre belirlediğini görür).
  final String email;
  final bool isLoading;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;

  @override
  State<ForgotNewPasswordFormWidget> createState() => _ForgotNewPasswordFormWidgetState();
}

class _ForgotNewPasswordFormWidgetState extends State<ForgotNewPasswordFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          spacing: AppSizes.spaceL,
          children: [
            Text(l10n.forgotNewPasswordInfo(widget.email), style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
            PasswordFormField(
              controller: _password,
              label: l10n.fieldNewPassword,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !widget.isLoading,
              validator: (v) => Validators.password(v)?.message(l10n),
            ),
            PasswordFormField(
              controller: _confirm,
              label: l10n.fieldPasswordConfirm,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => Validators.passwordConfirm(v, _password.text)?.message(l10n),
            ),
            AuthFormActionsWidget(
              isLoading: widget.isLoading,
              submitLabel: l10n.forgotResetButton,
              linkLabel: l10n.forgotBack,
              onSubmit: _submit,
              onLinkTap: widget.onBack,
            ),
          ],
        ),
      ),
    );
  }
}
