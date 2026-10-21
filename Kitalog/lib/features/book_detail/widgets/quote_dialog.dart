import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';

typedef QuoteInput = ({String text, int? page});

/// Yeni alıntı: metin (zorunlu) ve sayfa no (isteğe bağlı).
class QuoteDialog extends StatefulWidget {
  const QuoteDialog({super.key, required this.pageCount});

  final int pageCount;

  static Future<QuoteInput?> show(BuildContext context, {required int pageCount}) {
    return showDialog<QuoteInput>(
      context: context,
      builder: (_) => QuoteDialog(pageCount: pageCount),
    );
  }

  @override
  State<QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends State<QuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  final _page = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _page.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      text: _text.text.trim(),
      page: int.tryParse(_page.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.quoteAdd),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _text,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: l10n.quoteText),
              validator: (v) => Validators.required(v)?.message(l10n),
            ),
            TextFormField(
              controller: _page,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.quotePage),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _submit,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
