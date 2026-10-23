import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PasswordField({
    super.key,
    this.controller,
    required this.labelText,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autocorrect: false,
      autofillHints: const [AutofillHints.password],
    );
  }
}
