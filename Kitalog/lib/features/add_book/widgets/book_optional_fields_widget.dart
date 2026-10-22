import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/utils/validators.dart';

/// ISBN ve "bende var" anahtarı (kapak: `BookCoverFieldsWidget`).
class BookOptionalFieldsWidget extends StatelessWidget {
  const BookOptionalFieldsWidget({
    super.key,
    required this.isbn,
    required this.isOwned,
    required this.onOwnedChanged,
  });

  final TextEditingController isbn;
  final bool isOwned;
  final ValueChanged<bool> onOwnedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: AppSizes.spaceL,
      children: [
        TextFormField(
          controller: isbn,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: l10n.fieldBookIsbn),
          validator: (v) => Validators.optionalIsbn(v)?.message(l10n),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.fieldBookOwned),
          value: isOwned,
          onChanged: onOwnedChanged,
        ),
      ],
    );
  }
}
