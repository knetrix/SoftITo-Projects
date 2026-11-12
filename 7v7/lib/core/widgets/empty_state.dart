import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Boş durum (§2.9, `blank`): görsel/yelekler + 20/900 başlık +
/// 16 `ink2` açıklama + (varsa) birincil buton. 40/28 iç boşluk, 12 aralık.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.art,
    this.image,
    this.imageLabel,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.actionVariant = AppButtonVariant.pri,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
  });

  final String title;
  final String? description;
  final Widget? art;
  final String? image;
  final String? imageLabel;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final AppButtonVariant actionVariant;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null) ...[
            Semantics(
              image: true,
              label: imageLabel,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(image!,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
          ] else if (art != null) ...[
            art!,
            const SizedBox(height: 16),
          ],
          Semantics(
            header: true,
            child: Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSm(color: c.ink)),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(description!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(400, color: c.ink2)),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: actionLabel!,
              icon: actionIcon,
              variant: actionVariant,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
