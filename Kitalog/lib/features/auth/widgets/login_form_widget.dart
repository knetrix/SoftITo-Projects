import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/email_form_field.dart';
import '../../../core/widgets/password_form_field.dart';
import 'auth_form_actions_widget.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onRegisterTap,
  });

  final bool isLoading;
  final void Function(String email, String password) onSubmit;
  final VoidCallback onRegisterTap;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(Validators.normalizeEmail(_email.text), _password.text);
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
            PasswordFormField(
              controller: _password,
              label: l10n.fieldPassword,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => Validators.required(v)?.message(l10n),
            ),
            AuthFormActionsWidget(
              isLoading: widget.isLoading,
              submitLabel: l10n.buttonLogin,
              linkLabel: l10n.linkNoAccount,
              onSubmit: _submit,
              onLinkTap: widget.onRegisterTap,
            ),
          ],
        ),
      ),
    );
  }
}
