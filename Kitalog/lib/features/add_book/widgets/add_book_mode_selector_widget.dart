import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/add_book_model.dart';

class AddBookModeSelectorWidget extends StatelessWidget {
  const AddBookModeSelectorWidget({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final AddBookMode mode;
  final ValueChanged<AddBookMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AddBookMode>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: AddBookMode.search,
            icon: const Icon(Icons.search),
            label: Text(l10n.addBookModeSearch),
          ),
          ButtonSegment(
            value: AddBookMode.manual,
            icon: const Icon(Icons.edit_note),
            label: Text(l10n.addBookModeManual),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}
