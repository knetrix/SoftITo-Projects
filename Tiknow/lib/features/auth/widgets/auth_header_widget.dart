import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// Giriş/kayıt ekranı başlığı: marka simgesi, başlık ve alt başlık.
class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.local_taxi_rounded,
            size: 36,
            color: scheme.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.tr(titleKey),
          style: context.textStyles.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(subtitleKey),
          style: context.textStyles.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
