import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../services/account_service.dart';
import '../../services/auth_service.dart';
import '../../services/draft_service.dart';

/// Hesabı kalıcı olarak silme paneli (App Store 5.1.1(v), KVKK): şifreyle onay.
Future<void> showDeleteAccountSheet(BuildContext context) =>
    showAppSheet<void>(context, builder: (_) => const _DeleteSheet());

class _DeleteSheet extends ConsumerStatefulWidget {
  const _DeleteSheet();

  @override
  ConsumerState<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends ConsumerState<_DeleteSheet> {
  final _pw = TextEditingController();
  String? _err;
  bool _busy = false;

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_pw.text.isEmpty) {
      setState(() => _err = errorText(l, 'ePassword'));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      // Bekleyen taslak yazması silinen taslağı geri oluşturmasın.
      await ref.read(draftProvider.notifier).flush();
      await ref.read(accountServiceProvider).deleteAccount(_pw.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(l.accountDeleted);
    } on AuthFailure catch (f) {
      if (!mounted) return;
      if (f.field == 'password') {
        setState(() => _err = errorText(l, f.key));
      } else {
        AppToast.show(errorText(l, f.key));
      }
    } catch (e) {
      debugPrint('Hesap silme başarısız: $e');
      if (mounted) AppToast.show(l.eGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    return SheetBody(children: [
      Text(l.delH, style: AppTextStyles.titleSm(color: c.ink)),
      Text(l.delP, style: AppTextStyles.body(400, color: c.ink2)),
      AppTextField(
        label: l.fPw,
        controller: _pw,
        error: _err,
        password: true,
        autofillHints: const [AutofillHints.password],
        onChanged: (_) => _err == null ? null : setState(() => _err = null),
        onSubmitted: (_) => _submit(),
      ),
      const SizedBox(height: 6),
      AppButton(
        label: _busy ? l.delBusy : l.delBtn,
        variant: AppButtonVariant.danger,
        wide: true,
        onPressed: _busy ? null : _submit,
      ),
      AppButton(
        label: l.cancel,
        variant: AppButtonVariant.alt,
        wide: true,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    ]);
  }
}
