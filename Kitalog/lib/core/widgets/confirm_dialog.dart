import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Geri alınması zahmetli işlemler için onay penceresi: üstte simge, başlık ve
/// açıklama; altta tam genişlikte onay düğmesi ve onun altında "Vazgeç".
/// Düğmeler alt alta olduğu için uzun etiketler dar ekranda kaymaz.
abstract final class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    IconData? icon,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon == null ? null : Icon(icon, color: context.colors.primary),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
        actionsPadding: const EdgeInsets.fromLTRB(AppSizes.spaceXl, 0, AppSizes.spaceXl, AppSizes.spaceL),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.spaceXs,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.commonCancel),
              ),
            ],
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
