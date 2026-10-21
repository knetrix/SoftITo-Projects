import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/email_form_field.dart';
import '../../../core/widgets/password_form_field.dart';
import '../../../core/widgets/phone_form_field.dart';
import 'auth_form_actions_widget.dart';

/// Kayıt formu: `TextEditingController` ve `Form` anahtarının sahibi (yerel UI durumu).
class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final bool isLoading;
  final void Function(String email, String phone, String password) onSubmit;
  final VoidCallback onLoginTap;

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(
      Validators.normalizeEmail(_email.text),
      Validators.digitsOnly(_phone.text),
      _password.text,
    );
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
            EmailFormField(controller: _email, enabled: !widget.isLoading),
            PhoneFormField(controller: _phone, enabled: !widget.isLoading),
            PasswordFormField(
              controller: _password,
              label: l10n.fieldPassword,
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
              validator: (v) =>
                  Validators.passwordConfirm(v, _password.text)?.message(l10n),
            ),
            AuthFormActionsWidget(
              isLoading: widget.isLoading,
              submitLabel: l10n.buttonRegister,
              linkLabel: l10n.linkHaveAccount,
              onSubmit: _submit,
              onLinkTap: widget.onLoginTap,
            ),
          ],
        ),
      ),
    );
  }
}
