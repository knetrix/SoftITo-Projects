import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_extensions.dart';
import '../extensions/validation_extensions.dart';
import '../utils/phone_input_formatter.dart';
import '../utils/validators.dart';

/// Kayıt ve Ayarlar'da ortak kullanılan, `0 (5XX) XXX XX XX` maskeli telefon alanı.
class PhoneFormField extends StatelessWidget {
  const PhoneFormField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumber],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        const PhoneInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: l10n.fieldPhone,
        hintText: l10n.hintPhone,
        prefixIcon: const Icon(Icons.phone_outlined),
      ),
      validator: (value) => Validators.phone(value)?.message(l10n),
    );
  }
}
