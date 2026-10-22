import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/email_form_field.dart';
import '../../../core/widgets/phone_form_field.dart';
import 'auth_form_actions_widget.dart';

/// Şifremi unuttum 1. adım: kayıtlı e-posta ve telefon (kayıt ekranıyla aynı doğrulayıcılar).
class ForgotVerifyFormWidget extends StatefulWidget {
  const ForgotVerifyFormWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  final bool isLoading;
  final void Function(String email, String phone) onSubmit;
  final VoidCallback onBackToLogin;

  @override
  State<ForgotVerifyFormWidget> createState() => _ForgotVerifyFormWidgetState();
}

class _ForgotVerifyFormWidgetState extends State<ForgotVerifyFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(Validators.normalizeEmail(_email.text), Validators.digitsOnly(_phone.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        spacing: AppSizes.spaceL,
        children: [
          Text(l10n.forgotVerifyInfo, style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
          EmailFormField(controller: _email, enabled: !widget.isLoading),
          PhoneFormField(controller: _phone, enabled: !widget.isLoading),
          AuthFormActionsWidget(
            isLoading: widget.isLoading,
            submitLabel: l10n.forgotVerifyButton,
            linkLabel: l10n.forgotBackToLogin,
            onSubmit: _submit,
            onLinkTap: widget.onBackToLogin,
          ),
        ],
      ),
    );
  }
}
