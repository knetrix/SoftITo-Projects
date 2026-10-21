import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Detay ekranındaki bölümler için ortak başlıklı kart.
class SectionCardWidget extends StatelessWidget {
  const SectionCardWidget({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: context.textTheme.titleMedium)),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            child,
          ],
        ),
      ),
    );
  }
}
