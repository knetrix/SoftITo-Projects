import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/password_form_field.dart';

/// Şifre güncelleme: mevcut şifre doğrulanır, yeni şifre kayıt kurallarına uyar.
class PasswordUpdateFormWidget extends StatefulWidget {
  const PasswordUpdateFormWidget({
    super.key,
    required this.currentPasswordWrong,
    required this.onSave,
    required this.onEdited,
  });

  final bool currentPasswordWrong;
  final Future<bool> Function(String current, String next) onSave;
  final VoidCallback onEdited;

  @override
  State<PasswordUpdateFormWidget> createState() =>
      _PasswordUpdateFormWidgetState();
}

class _PasswordUpdateFormWidgetState extends State<PasswordUpdateFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.onSave(_current.text, _next.text);
    if (ok && mounted) {
      _formKey.currentState?.reset();
      _current.clear();
      _next.clear();
      _confirm.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      onChanged: widget.onEdited,
      child: Column(
        spacing: AppSizes.spaceM,
        children: [
          PasswordFormField(
            controller: _current,
            label: l10n.fieldCurrentPassword,
            validator: (v) => Validators.required(v)?.message(l10n),
          ),
          if (widget.currentPasswordWrong) const _WrongPasswordText(),
          PasswordFormField(
            controller: _next,
            label: l10n.fieldNewPassword,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) => Validators.password(v)?.message(l10n),
          ),
          PasswordFormField(
            controller: _confirm,
            label: l10n.fieldPasswordConfirm,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) =>
                Validators.passwordConfirm(v, _next.text)?.message(l10n),
          ),
          FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}

class _WrongPasswordText extends StatelessWidget {
  const _WrongPasswordText();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        context.l10n.errorWrongCurrentPassword,
        style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
      ),
    );
  }
}
