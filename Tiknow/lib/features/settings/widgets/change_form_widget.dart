import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// E-posta / telefon / şifre değiştirme ekranlarının ortak iskeleti.
/// [onSubmit] hata anahtarı (`null` = başarılı) döner; başarıda bilgi
/// mesajı gösterilir ve ekran kapanır.
class ChangeFormWidget extends StatefulWidget {
  const ChangeFormWidget({
    super.key,
    required this.titleKey,
    required this.formKey,
    required this.fields,
    required this.onSubmit,
  });

  final String titleKey;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final Future<String?> Function() onSubmit;

  @override
  State<ChangeFormWidget> createState() => _ChangeFormWidgetState();
}

class _ChangeFormWidgetState extends State<ChangeFormWidget> {
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _busy.dispose();
    _error.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(widget.formKey.currentState?.validate() ?? false)) return;
    _busy.value = true;
    _error.value = null;
    final error = await widget.onSubmit();
    if (!mounted) return;
    _busy.value = false;
    if (error != null) {
      _error.value = error;
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('saved'))),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(widget.titleKey))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final field in widget.fields) ...[
                  field,
                  const SizedBox(height: 14),
                ],
                _ErrorLine(error: _error),
                const SizedBox(height: 8),
                _SaveButton(busy: _busy, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.error});

  final ValueListenable<String?> error;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: error,
      builder: (context, key, _) {
        if (key == null) return const SizedBox.shrink();
        return Text(
          context.tr(key),
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.busy, required this.onPressed});

  final ValueListenable<bool> busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: busy,
      builder: (context, isBusy, _) {
        return FilledButton(
          onPressed: isBusy ? null : onPressed,
          child: Text(context.tr('save')),
        );
      },
    );
  }
}
