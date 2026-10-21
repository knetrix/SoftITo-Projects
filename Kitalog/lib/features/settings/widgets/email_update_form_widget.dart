import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/email_form_field.dart';

/// E-posta güncelleme formu (kayıt ekranıyla aynı alan ve validator).
class EmailUpdateFormWidget extends StatefulWidget {
  const EmailUpdateFormWidget({
    super.key,
    required this.initialEmail,
    required this.onSave,
  });

  final String initialEmail;
  final Future<bool> Function(String email) onSave;

  @override
  State<EmailUpdateFormWidget> createState() => _EmailUpdateFormWidgetState();
}

class _EmailUpdateFormWidgetState extends State<EmailUpdateFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSave(Validators.normalizeEmail(_email.text));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: AppSizes.spaceM,
        children: [
          EmailFormField(
            controller: _email,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          FilledButton(onPressed: _submit, child: Text(context.l10n.commonSave)),
        ],
      ),
    );
  }
}
