import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state_view.dart';

/// Kitap cihazda değilken indirme çağrısı; indirme sürerken ilerleme gösterir.
class ReaderDownloadWidget extends StatelessWidget {
  const ReaderDownloadWidget({
    super.key,
    required this.isDownloading,
    required this.progress,
    required this.supportsOffline,
    required this.onDownload,
  });

  final bool isDownloading;
  final double progress;
  final bool supportsOffline;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isDownloading) {
      final percent = (progress * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSizes.spaceM,
            children: [
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              Text(l10n.readerDownloading(percent), style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }
    return EmptyStateView(
      icon: Icons.download_for_offline_outlined,
      title: l10n.readerDownloadTitle,
      message: supportsOffline ? l10n.readerDownloadMessage : l10n.readerDownloadWebNote,
      action: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        onPressed: onDownload,
        icon: const Icon(Icons.download),
        label: Text(l10n.readerDownloadButton),
      ),
    );
  }
}
