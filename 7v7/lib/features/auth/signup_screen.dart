import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_icons.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/icon_circle_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/legal_sheet.dart';

/// 03 Hesap oluştur (§3): onay kutuları butonun altında; başarıda oturum
/// kapatılır ve e-posta dolu olarak girişe dönülür.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  bool _terms = false, _kvkk = false, _busy = false;
  final Map<String, String?> _err = {};

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _pw]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clear(String k) {
    if (_err[k] != null) setState(() => _err[k] = null);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final e = <String, String?>{
      'first': Validators.firstName(_first.text),
      'last': Validators.lastName(_last.text),
      'email': Validators.email(_email.text),
      'phone': Validators.phone(_phone.text),
      'password': Validators.newPassword(_pw.text),
      'terms': _terms ? null : 'eTerms',
      'kvkk': _kvkk ? null : 'eKvkk',
    };
    setState(() {
      _err
        ..clear()
        ..addAll({for (final x in e.entries) x.key: x.value == null ? null : errorText(l, x.value!)});
    });
    if (e.values.any((v) => v != null)) return;

    setState(() => _busy = true);
    final settings = ref.read(settingsProvider);
    try {
      await ref.read(authServiceProvider).signUp(
            firstName: _first.text,
            lastName: _last.text,
            email: _email.text,
            phone: _phone.text,
            password: _pw.text,
            locale: settings.locale.languageCode,
            themeMode: settings.themeKey,
          );
      if (!mounted) return;
      context.go(Uri(path: '/signin', queryParameters: {
        'email': _email.text.trim(),
        'created': '1',
      }).toString());
    } on AuthFailure catch (f) {
      if (!mounted) return;
      if (f.field != null) {
        setState(() => _err[f.field!] = errorText(l, f.key));
      } else {
        AppToast.show(errorText(l, f.key));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);
    Widget? errLine(String k) => _err[k] == null
        ? null
        : Padding(padding: const EdgeInsets.only(top: 0), child: FieldError(_err[k]!));

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, mq.padding.top + 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconCircleButton(
                icon: PhosphorIconsFill.caretLeft,
                semanticLabel: l.back,
                onPressed: () => goBack(context, '/signin'),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 32 + mq.padding.bottom / 2),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(header: true, child: Text(l.suH, style: AppTextStyles.title(color: c.ink))),
                    const SizedBox(height: 6),
                    Text(l.suP, style: AppTextStyles.body(400, color: c.ink2)),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: l.fFirst,
                            controller: _first,
                            error: _err['first'],
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.givenName],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _clear('first'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: l.fLast,
                            controller: _last,
                            error: _err['last'],
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.familyName],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _clear('last'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l.fEmail,
                      controller: _email,
                      error: _err['email'],
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clear('email'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l.fPhone,
                      controller: _phone,
                      error: _err['phone'],
                      placeholder: '05XX XXX XX XX',
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clear('phone'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l.fPw,
                      controller: _pw,
                      error: _err['password'],
                      hint: l.pwHint,
                      password: true,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => _clear('password'),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: _busy ? l.suBusy : l.suBtn,
                      wide: true,
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: 16),
                    AgreeCheck(
                      value: _terms,
                      semanticLabel: l.chkTerms,
                      linkText: l.agreeTermsA,
                      suffix: l.agreeSuffix,
                      error: errLine('terms'),
                      onChanged: (v) => setState(() {
                        _terms = v;
                        _err['terms'] = null;
                      }),
                      onLink: () async {
                        if (await showLegalSheet(context, LegalKind.terms) && mounted) {
                          setState(() {
                            _terms = true;
                            _err['terms'] = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AgreeCheck(
                      value: _kvkk,
                      semanticLabel: l.chkKvkk,
                      linkText: l.agreeKvkkA,
                      suffix: l.agreeSuffix,
                      error: errLine('kvkk'),
                      onChanged: (v) => setState(() {
                        _kvkk = v;
                        _err['kvkk'] = null;
                      }),
                      onLink: () async {
                        if (await showLegalSheet(context, LegalKind.kvkk) && mounted) {
                          setState(() {
                            _kvkk = true;
                            _err['kvkk'] = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SwapRow(text: l.hasAcct, link: l.toSignin, onTap: () => goBack(context, '/signin')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
