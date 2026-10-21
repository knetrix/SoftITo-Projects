import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/digital_extensions.dart';
import '../../../core/models/digital_edition_model.dart';
import '../models/digital_edition_actions.dart';
import '../models/digital_edition_state.dart';

/// Dijital sürümü olan kitap: İndir (ilerlemesiyle) / Oku / Sil; kullanıcı
/// dosyasında "Başka dosya yükle".
class DigitalAvailableWidget extends StatelessWidget {
  const DigitalAvailableWidget({
    super.key,
    required this.edition,
    required this.state,
    required this.actions,
    required this.onRead,
  });

  final DigitalEditionModel edition;
  final DigitalEditionState state;
  final DigitalEditionActions actions;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = state.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.spaceS,
      children: [
        if (state.isDownloading) _DownloadProgress(progress: state.progress),
        if (error != null)
          Text(
            error.message(l10n),
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
          ),
        if (state.isDownloaded) ...[
          FilledButton.icon(
            onPressed: onRead,
            icon: const Icon(Icons.chrome_reader_mode_outlined),
            label: Text(l10n.digitalRead),
          ),
          if (edition.isLocalFile)
            TextButton.icon(
              onPressed: state.isBusy ? null : actions.importFile,
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.digitalReplaceFile),
            ),
          TextButton.icon(
            onPressed: actions.deleteCopy,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.digitalDelete),
          ),
        ] else
          FilledButton.icon(
            onPressed: state.isDownloading ? null : actions.download,
            icon: const Icon(Icons.download_for_offline_outlined),
            label: Text(l10n.digitalDownload),
          ),
      ],
    );
  }
}

class _DownloadProgress extends StatelessWidget {
  const _DownloadProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.spaceXs,
      children: [
        LinearProgressIndicator(value: progress > 0 ? progress : null),
        Text(
          context.l10n.readerDownloading((progress * 100).round()),
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}
