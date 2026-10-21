import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/phone_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/phone_form_field.dart';

/// Telefon güncelleme formu (kayıt ekranıyla aynı maske ve validator).
class PhoneUpdateFormWidget extends StatefulWidget {
  const PhoneUpdateFormWidget({
    super.key,
    required this.initialPhone,
    required this.onSave,
  });

  final String initialPhone;
  final Future<bool> Function(String phoneDigits) onSave;

  @override
  State<PhoneUpdateFormWidget> createState() => _PhoneUpdateFormWidgetState();
}

class _PhoneUpdateFormWidgetState extends State<PhoneUpdateFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone = TextEditingController(
    text: PhoneInputFormatter.format(widget.initialPhone),
  );

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSave(Validators.digitsOnly(_phone.text));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: AppSizes.spaceM,
        children: [
          PhoneFormField(
            controller: _phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          FilledButton(onPressed: _submit, child: Text(context.l10n.commonSave)),
        ],
      ),
    );
  }
}
