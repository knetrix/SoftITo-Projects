import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';

/// Mevcut sayfayı doğrudan girmek için diyalog (0 - sayfa sayısı).
class PageInputDialog extends StatefulWidget {
  const PageInputDialog({super.key, required this.book});

  final BookModel book;

  static Future<int?> show(BuildContext context, BookModel book) {
    return showDialog<int>(
      context: context,
      builder: (_) => PageInputDialog(book: book),
    );
  }

  @override
  State<PageInputDialog> createState() => _PageInputDialogState();
}

class _PageInputDialogState extends State<PageInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.book.currentPage.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null) return;
    Navigator.of(context).pop(value.clamp(0, widget.book.pageCount));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pageEditTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.pageEditLabel(widget.book.pageCount),
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
