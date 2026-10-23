// Component: [ComponentName]
// Konum: lib/features/<feature_name>/widgets/<component_name>.dart
//        veya feature'lar arası ortaksa lib/core/widgets/<component_name>.dart
//
// Kurallar:
// - StatelessWidget + const constructor; state controller'da tutulur.
// - Veriyi parametre ile al, aksiyonları callback (VoidCallback / ValueChanged) ile dışarı ver.
// - Renk/stil: context.colors / context.textStyles; metin: context.l10n.
// - build() 40 satırı geçerse alt widget'lara böl.

import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class ComponentName extends StatelessWidget {
  // TODO: Gerekli alanları tanımla (para alanları int kuruş)
  final String title;
  final VoidCallback? onTap;

  const ComponentName({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: context.textStyles.titleMedium),
        trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
