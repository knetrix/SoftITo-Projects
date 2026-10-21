import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';

/// Başlık, yazar(lar) ve sayfa sayısı alanları.
class BookIdentityFieldsWidget extends StatelessWidget {
  const BookIdentityFieldsWidget({
    super.key,
    required this.title,
    required this.authors,
    required this.pages,
  });

  final TextEditingController title;
  final TextEditingController authors;
  final TextEditingController pages;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: AppSizes.spaceL,
      children: [
        TextFormField(
          controller: title,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: l10n.fieldBookTitle),
          validator: (v) => Validators.required(v)?.message(l10n),
        ),
        TextFormField(
          controller: authors,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.fieldBookAuthors,
            helperText: l10n.fieldBookAuthorsHelper,
          ),
        ),
        TextFormField(
          controller: pages,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: l10n.fieldBookPages),
          validator: (v) => Validators.positiveInt(v)?.message(l10n),
        ),
      ],
    );
  }
}
