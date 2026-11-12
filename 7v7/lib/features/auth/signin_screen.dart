import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_link.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/forgot_password_sheet.dart';

/// 02 Giriş (§3): e-posta + şifre, şifremi unuttum.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.prefillEmail, this.created = false});
  final String? prefillEmail;
  final bool created;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final _ident = TextEditingController(text: widget.prefillEmail ?? '');
  final _pw = TextEditingController();
  String? _identErr, _pwErr;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.created) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppToast.show(AppLocalizations.of(context).accountCreated);
      });
    }
  }

  @override
  void dispose() {
    _ident.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final ie = Validators.email(_ident.text);
    final pe = Validators.password(_pw.text);
    setState(() {
      _identErr = ie == null ? null : errorText(l, ie);
      _pwErr = pe == null ? null : errorText(l, pe);
    });
    if (ie != null || pe != null) return;
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signIn(_ident.text, _pw.text);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      final msg = errorText(l, e.key);
      setState(() {
        if (e.field == 'password') {
          _pwErr = msg;
        } else if (e.field == 'ident') {
          _identErr = msg;
        } else {
          AppToast.show(msg);
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, mq.padding.top + 8, 24, 32 + mq.padding.bottom / 2),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Brand()),
              const SizedBox(height: 20),
              Semantics(
                image: true,
                label: l.imgSignin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/images/signin.jpg', height: 140, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(header: true, child: Text(l.siH, style: AppTextStyles.title(color: c.ink))),
              const SizedBox(height: 6),
              Text(l.siP, style: AppTextStyles.body(400, color: c.ink2)),
              const SizedBox(height: 20),
              AppTextField(
                label: l.fEmail,
                controller: _ident,
                error: _identErr,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) => _identErr == null ? null : setState(() => _identErr = null),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l.fPw,
                controller: _pw,
                error: _pwErr,
                password: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                onChanged: (_) => _pwErr == null ? null : setState(() => _pwErr = null),
              ),
              const SizedBox(height: 16 - 8),
              Align(
                alignment: Alignment.centerRight,
                child: AppLink(
                  text: l.forgot,
                  ink: true,
                  small: true,
                  onTap: () => showForgotPasswordSheet(
                    context,
                    initialEmail: _ident.text.contains('@') ? _ident.text.trim() : '',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: _busy ? l.siBusy : l.siBtn,
                wide: true,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 24),
              SwapRow(text: l.noAcct, link: l.toSignup, onTap: () => context.push('/signup')),
            ],
          ),
        ),
      ),
    );
  }
}
