import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/utils/validators.dart';
import '../models/add_book_model.dart';

/// Hızlı kategori ekleme: ad (zorunlu, benzersiz) ve renk. Ad alanı ve seçili
/// renk yerel UI durumudur.
class NewGenreDialog extends StatefulWidget {
  const NewGenreDialog({super.key, required this.takenNames, required this.initialColor});

  /// Yerleşik tür etiketleri ve mevcut kategori adları (tekrarı önlemek için).
  final List<String> takenNames;
  final int initialColor;

  static Future<NewGenreInput?> show(
    BuildContext context, {
    required List<String> takenNames,
    required int initialColor,
  }) {
    return showDialog<NewGenreInput>(
      context: context,
      builder: (_) => NewGenreDialog(takenNames: takenNames, initialColor: initialColor),
    );
  }

  @override
  State<NewGenreDialog> createState() => _NewGenreDialogState();
}

class _NewGenreDialogState extends State<NewGenreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late int _color = widget.initialColor;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((name: CustomGenreModel.cleanName(_name.text), colorIndex: _color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.genreNewTitle),
      // Dar ekranda ve büyük yazıda içerik kaydırılabilir kalır.
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.spaceL,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: CustomGenreModel.maxNameLength,
                decoration: InputDecoration(labelText: l10n.genreNewName),
                validator: (v) => Validators.genreName(v, widget.takenNames)?.message(l10n),
                onFieldSubmitted: (_) => _submit(),
              ),
              Text(l10n.genreNewColor, style: context.textTheme.labelLarge),
              _ColorPalette(selected: _color, onSelected: (i) => setState(() => _color = i)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.genreNewSave)),
      ],
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spaceS,
      runSpacing: AppSizes.spaceS,
      children: [
        for (var i = 0; i < AppColors.customGenrePalette.length; i++)
          Semantics(
            selected: i == selected,
            child: IconButton(
              tooltip: context.l10n.genreColorOption(i + 1),
              onPressed: () => onSelected(i),
              style: IconButton.styleFrom(backgroundColor: AppColors.customGenrePalette[i]),
              icon: Icon(i == selected ? Icons.check : null, color: AppColors.onGenre),
            ),
          ),
      ],
    );
  }
}
