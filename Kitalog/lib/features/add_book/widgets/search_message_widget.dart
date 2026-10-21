import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/add_book_model.dart';

/// Arama hatası / sonuç yok durumunda "tekrar dene" ve "manuel ekle" seçenekleri.
class SearchMessageWidget extends StatelessWidget {
  const SearchMessageWidget({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onManual,
  });

  final AddBookError error;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, message) = switch (error) {
      AddBookError.emptyQuery => (Icons.search, l10n.addBookErrorEmptyQuery),
      AddBookError.invalidIsbn => (Icons.pin_outlined, l10n.addBookErrorInvalidIsbn),
      AddBookError.notFound => (Icons.search_off, l10n.addBookErrorNotFound),
      AddBookError.network => (Icons.wifi_off, l10n.addBookErrorNetwork),
      AddBookError.server => (Icons.cloud_off, l10n.addBookErrorServer),
      AddBookError.duplicate => (Icons.copy_all, l10n.addBookErrorDuplicate),
    };
    final canRetry =
        error == AddBookError.network || error == AddBookError.server;
    return EmptyStateView(
      icon: icon,
      title: message,
      action: Wrap(
        spacing: AppSizes.spaceM,
        runSpacing: AppSizes.spaceS,
        alignment: WrapAlignment.center,
        children: [
          if (canRetry)
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: onRetry,
              child: Text(l10n.commonRetry),
            ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: onManual,
            child: Text(l10n.addBookGoManual),
          ),
        ],
      ),
    );
  }
}
