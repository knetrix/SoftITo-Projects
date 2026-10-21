import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/note_model.dart';
import 'section_card_widget.dart';
import 'text_entry_dialog.dart';

class NotesSectionWidget extends StatelessWidget {
  const NotesSectionWidget({
    super.key,
    required this.notes,
    required this.onAdd,
    required this.onDelete,
  });

  final List<NoteModel> notes;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCardWidget(
      title: l10n.notesSectionTitle,
      trailing: IconButton(
        tooltip: l10n.noteAdd,
        icon: const Icon(Icons.note_add_outlined),
        onPressed: () async {
          final text = await TextEntryDialog.show(
            context,
            title: l10n.noteAdd,
            label: l10n.noteContent,
          );
          if (text != null) onAdd(text);
        },
      ),
      child: notes.isEmpty
          ? Text(l10n.notesEmpty, style: context.textTheme.bodyMedium)
          : Column(
              children: [
                for (final note in notes)
                  _NoteTile(
                    key: ValueKey(note.id),
                    note: note,
                    onDelete: () => onDelete(note.id),
                  ),
              ],
            ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({super.key, required this.note, required this.onDelete});

  final NoteModel note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_outlined, size: AppSizes.iconM),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.content, style: context.textTheme.bodyMedium),
                Text(
                  context.formatDate(note.updatedAt),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.noteDelete,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
