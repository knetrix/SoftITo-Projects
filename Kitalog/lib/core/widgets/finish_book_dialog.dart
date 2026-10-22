import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'confirm_dialog.dart';

/// "Kitabı bitirdin mi?" onayı. Hem "Bitti olarak işaretle" düğmesi hem de son
/// sayfaya ulaşıldığında (Kitap Detay, Okuma Durumu, okuyucu) aynı pencere açılır.
abstract final class FinishBookDialog {
  /// [reachedEnd]: son sayfaya ulaşıldığı için kendiliğinden açıldı (açıklama buna göre).
  static Future<bool> show(BuildContext context, {bool reachedEnd = false}) {
    final l10n = context.l10n;
    return ConfirmDialog.show(
      context,
      icon: Icons.check_circle_outline,
      title: l10n.finishConfirmTitle,
      message: reachedEnd ? l10n.finishReachedMessage : l10n.finishConfirmMessage,
      confirmLabel: l10n.markFinished,
    );
  }
}
