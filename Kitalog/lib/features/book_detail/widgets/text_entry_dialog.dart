import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// Tek alanlı (çok satırlı) metin girişi diyaloğu: inceleme ve not için.
class TextEntryDialog extends StatefulWidget {
  const TextEntryDialog({
    super.key,
    required this.title,
    required this.label,
    this.initialText = '',
    this.allowEmpty = false,
  });

  final String title;
  final String label;
  final String initialText;
  final bool allowEmpty;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String label,
    String initialText = '',
    bool allowEmpty = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => TextEntryDialog(
        title: title,
        label: label,
        initialText: initialText,
        allowEmpty: allowEmpty,
      ),
    );
  }

  @override
  State<TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<TextEntryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && !widget.allowEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(labelText: widget.label),
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
