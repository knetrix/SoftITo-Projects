import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/l10n_keys.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';

/// Panel `forgot` (§3 ekran 02). Firebase'de yeni şifre alanı yoktur:
/// `sendPasswordResetEmail` ile yenileme bağlantısı gönderilir (§11).
Future<void> showForgotPasswordSheet(BuildContext context, {String initialEmail = ''}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _ForgotSheet(initialEmail: initialEmail),
  );
}

class _ForgotSheet extends ConsumerStatefulWidget {
  const _ForgotSheet({required this.initialEmail});
  final String initialEmail;

  @override
  ConsumerState<_ForgotSheet> createState() => _ForgotSheetState();
}

class _ForgotSheetState extends ConsumerState<_ForgotSheet> {
  late final _email = TextEditingController(text: widget.initialEmail);
  String? _err;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final e = Validators.email(_email.text);
    if (e != null) {
      setState(() => _err = errorText(l, e));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_email.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(l.fpSent);
    } on AuthFailure catch (f) {
      if (mounted) setState(() => _err = errorText(l, f.key));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SheetBody(children: [
      SheetTitle(l.fpH, sub: l.fpP),
      const SizedBox(height: 6),
      AppTextField(
        label: l.fEmail,
        controller: _email,
        error: _err,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        onChanged: (_) => _err == null ? null : setState(() => _err = null),
        onSubmitted: (_) => _submit(),
      ),
      const SizedBox(height: 6),
      AppButton(label: _busy ? l.fpBusy : l.fpBtn, wide: true, onPressed: _busy ? null : _submit),
      AppButton(
        label: l.cancel,
        variant: AppButtonVariant.alt,
        wide: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ]);
  }
}
