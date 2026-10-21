import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/digital_extensions.dart';
import '../../../core/repositories/digital_sources/source_http.dart';
import '../../../core/widgets/empty_state_view.dart';

class ReaderErrorWidget extends StatelessWidget {
  const ReaderErrorWidget({super.key, required this.error, required this.onRetry});

  final DigitalBookFailure? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = (error ?? DigitalBookFailure.unavailable).message(l10n);
    final canRetry = error?.isRetryable ?? false;
    return EmptyStateView(
      icon: error == DigitalBookFailure.network ? Icons.wifi_off : Icons.error_outline,
      title: message,
      action: canRetry
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: onRetry,
              child: Text(l10n.commonRetry),
            )
          : null,
    );
  }
}
