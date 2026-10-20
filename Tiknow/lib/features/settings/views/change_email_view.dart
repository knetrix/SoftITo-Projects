import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../auth/widgets/auth_text_field_widget.dart';
import '../controllers/profile_controller.dart';
import '../widgets/change_form_widget.dart';

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.controller.profile.value.email,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeFormWidget(
      titleKey: 'change_email',
      formKey: _formKey,
      onSubmit: () => widget.controller.changeEmail(_email.text),
      fields: [
        AuthTextFieldWidget(
          controller: _email,
          labelKey: 'new_email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: Validators.email,
        ),
      ],
    );
  }
}
