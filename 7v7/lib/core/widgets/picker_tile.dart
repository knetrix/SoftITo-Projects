import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// Seçici `pick` (§2.9): 56 min, köşe 16, `card` zemin, 1.5 `line`;
/// üstte 12/600 `ink2` etiket, altta 14/800 değer; boşsa "Seç";
/// hatalıysa 2 px `error` kontur + "Gerekli".
class PickerTile extends StatelessWidget {
  const PickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.requiredText,
    this.error = false,
    this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final String requiredText;
  final bool error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final empty = value == null || value!.isEmpty;
    final shown = error && empty ? requiredText : (empty ? placeholder : value!);
    final valueStyle = error && empty
        ? AppTextStyles.bodySm(800, color: c.error)
        : empty
            ? AppTextStyles.bodySm(600, color: c.ink2)
            : AppTextStyles.bodySm(800, color: c.ink);
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label, $shown',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: _pickDecoration(c, error),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label(600, color: c.ink2)),
              const SizedBox(height: 2),
              Text(shown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _pickDecoration(AppColors c, bool error) => BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: error ? c.error : c.line,
        width: error ? 2 : 1.5,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );

/// Geniş seçici (`pick wide`): ikon + etiket/değer + sağda ek metin.
class WidePickerTile extends StatelessWidget {
  const WidePickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.requiredText,
    this.trailing,
    this.error = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final String requiredText;
  final String? trailing;
  final bool error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final empty = value == null || value!.isEmpty;
    final shown = error && empty ? requiredText : (empty ? placeholder : value!);
    final valueStyle = error && empty
        ? AppTextStyles.bodySm(800, color: c.error)
        : empty
            ? AppTextStyles.bodySm(600, color: c.ink2)
            : AppTextStyles.bodySm(800, color: c.ink, tabular: true);
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label, $shown',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: _pickDecoration(c, error),
          child: Row(
            children: [
              Icon(icon, size: 24, color: c.ink2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.label(600, color: c.ink2)),
                    const SizedBox(height: 2),
                    Text(shown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: valueStyle),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                Text(trailing!,
                    style: AppTextStyles.bodySm(400, color: c.ink2)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
