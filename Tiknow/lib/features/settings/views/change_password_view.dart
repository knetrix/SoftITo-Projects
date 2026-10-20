import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../auth/widgets/auth_text_field_widget.dart';
import '../controllers/profile_controller.dart';
import '../widgets/change_form_widget.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeFormWidget(
      titleKey: 'change_password',
      formKey: _formKey,
      onSubmit: () => widget.controller.changePassword(
        oldPassword: _old.text,
        newPassword: _new.text,
        newPasswordConfirm: _confirm.text,
      ),
      fields: [
        AuthTextFieldWidget(
          controller: _old,
          labelKey: 'old_password',
          icon: Icons.lock_clock_outlined,
          obscure: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'err_password_required' : null,
        ),
        AuthTextFieldWidget(
          controller: _new,
          labelKey: 'new_password',
          icon: Icons.lock_outline,
          obscure: true,
          validator: Validators.password,
        ),
        AuthTextFieldWidget(
          controller: _confirm,
          labelKey: 'password_confirm',
          icon: Icons.lock_reset,
          obscure: true,
          textInputAction: TextInputAction.done,
          validator: (v) => Validators.passwordConfirm(v, _new.text),
        ),
      ],
    );
  }
}
