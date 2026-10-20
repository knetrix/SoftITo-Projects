import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../auth/widgets/auth_text_field_widget.dart';
import '../controllers/profile_controller.dart';
import '../widgets/change_form_widget.dart';

class ChangePhoneView extends StatefulWidget {
  const ChangePhoneView({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<ChangePhoneView> createState() => _ChangePhoneViewState();
}

class _ChangePhoneViewState extends State<ChangePhoneView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone = TextEditingController(
    text: widget.controller.profile.value.phone,
  );

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeFormWidget(
      titleKey: 'change_phone',
      formKey: _formKey,
      onSubmit: () => widget.controller.changePhone(_phone.text),
      fields: [
        AuthTextFieldWidget(
          controller: _phone,
          labelKey: 'new_phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          validator: Validators.phone,
        ),
      ],
    );
  }
}
