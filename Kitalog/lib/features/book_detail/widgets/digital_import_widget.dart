import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/digital_extensions.dart';
import '../models/digital_edition_actions.dart';
import '../models/digital_edition_state.dart';

/// Dijital sürümü olmayan kitap: kullanıcı kendi PDF / EPUB dosyasını yükler.
class DigitalImportWidget extends StatelessWidget {
  const DigitalImportWidget({
    super.key,
    required this.state,
    required this.actions,
  });

  final DigitalEditionState state;
  final DigitalEditionActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = state.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.spaceS,
      children: [
        Text(l10n.digitalImportHint, style: context.textTheme.bodyMedium),
        if (state.isImporting) ...[
          const LinearProgressIndicator(),
          Text(l10n.digitalImporting, style: context.textTheme.bodySmall),
        ] else
          OutlinedButton.icon(
            onPressed: actions.importFile,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.digitalImportButton),
          ),
        if (error != null)
          Text(
            error.message(l10n),
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
          ),
      ],
    );
  }
}
